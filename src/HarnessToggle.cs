// HarnessToggle — DeepSeek Harness one-click GUI toggler.
// Compile (on this machine the harness uses PowerShell Add-Type) to a native
// Windows GUI .exe with:
//   Add-Type -TypeDefinition (Get-Content -Raw HarnessToggle.cs) -Language CSharp`
//     -ReferencedAssemblies WinForms, Drawing -OutputType WindowsApplication`
//     -OutputAssembly HarnessToggle.exe
// Requires only Windows + .NET Framework 4.x (built into Windows 10/11).

using System;
using System.Diagnostics;
using System.Drawing;
using System.Threading;
using System.Windows.Forms;

public class HarnessToggle
{
    const string NPX_PKG   = "@deepseek-ai/dsh web";
    const int    PORT      = 3080;
    const string URL       = "http://127.0.0.1:3080";

    private Button  btn;
    private Label   status;
    private bool    running;
    private Thread  openBrowserThread;

    [STAThread]
    public static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        new HarnessToggle().Run();
    }

    private void Run()
    {
        var f = new Form();
        f.Text        = "DeepSeek Harness 控制";
        f.StartPosition = FormStartPosition.CenterScreen;
        f.ClientSize  = new Size(360, 150);
        f.MinimizeBox = true;
        f.MaximizeBox = false;
        f.FormBorderStyle = FormBorderStyle.FixedSingle;
        f.Icon        = SystemIcons.Application;

        var panel = new TableLayoutPanel();
        panel.Dock = DockStyle.Fill;
        panel.RowCount = 2;
        panel.ColumnCount = 1;
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 60f));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 40f));

        btn = new Button();
        btn.Dock = DockStyle.Fill;
        btn.Font = new Font("Segoe UI", 15f, FontStyle.Bold);
        btn.Margin = new Padding(20, 12, 20, 4);
        btn.Click += (s, e) => Toggle();
        panel.Controls.Add(btn, 0, 0);

        status = new Label();
        status.Dock = DockStyle.Fill;
        status.TextAlign = ContentAlignment.MiddleCenter;
        status.Font = new Font("Segoe UI", 9.5f);
        status.ForeColor = Color.DimGray;
        panel.Controls.Add(status, 0, 1);

        f.Controls.Add(panel);

        // Initialize button state from reality.
        running = IsListening(PORT);
        UpdateUI("就绪");
        if (running)
        {
            btn.Text = "关闭";
            status.Text = "Harness 运行中 · 端口 " + PORT;
        }
        else
        {
            btn.Text = "启动";
            status.Text = "Harness 未运行";
        }

        f.FormClosing += (s, e) =>
        {
            try { if (openBrowserThread != null && openBrowserThread.IsAlive) openBrowserThread.Abort(); }
            catch { }
        };

        Application.Run(f);
    }

    private void Toggle()
    {
        if (running) Stop();
        else         Start();
        running = IsListening(PORT);
        UpdateUI(string.Empty);
    }

    private void Start()
    {
        try
        {
            // Launch the official DeepSeek Harness web profile with NO console window.
            var psi = new ProcessStartInfo();
            psi.FileName               = "cmd.exe";
            psi.Arguments              = "/c npx " + NPX_PKG;
            psi.CreateNoWindow         = true;
            psi.UseShellExecute        = false;
            psi.WindowStyle            = ProcessWindowStyle.Hidden;
            psi.RedirectStandardOutput = false;
            Process.Start(psi);

            status.Text = "正在启动 Harness…";

            // Open the browser once the port is up.
            openBrowserThread = new Thread(new ThreadStart(delegate
            {
                try
                {
                    // Poll for readiness (max ~60 s), then open the browser.
                    for (int i = 0; i < 120; i++)
                    {
                        Thread.Sleep(500);
                        if (IsListening(PORT))
                        {
                            Process.Start("explorer.exe", '"' + URL + '"');
                            return;
                        }
                    }
                    Process.Start("explorer.exe", '"' + URL + '"');
                }
                catch { }
            }));
            openBrowserThread.IsBackground = true;
            openBrowserThread.Start();
        }
        catch (Exception ex)
        {
            status.Text = "启动失败: " + ex.Message;
            UpdateUI(ex.Message);
        }
    }

    private void Stop()
    {
        try
        {
            // Kill the process tree that is listening on the port.
            string pidStr = GetListeningPid(PORT);
            if (!string.IsNullOrEmpty(pidStr))
            {
                var psi = new ProcessStartInfo();
                psi.FileName               = "taskkill.exe";
                psi.Arguments              = "/PID " + pidStr + " /T /F";
                psi.CreateNoWindow         = true;
                psi.UseShellExecute        = false;
                psi.WindowStyle            = ProcessWindowStyle.Hidden;
                Process.Start(psi).WaitForExit();
            }
            status.Text = "正在停止 Harness…";
        }
        catch (Exception ex)
        {
            status.Text = "停止出错: " + ex.Message;
        }
    }

    private void UpdateUI(string note)
    {
        // Called from UI thread; safe.
        btn.Text = running ? "关闭" : "启动";
        status.Text = running
            ? "Harness 运行中 · 端口 " + PORT
            : "Harness 未运行";
        if (!string.IsNullOrEmpty(note)) status.Text = note;
    }

    private static bool IsListening(int port)
    {
        return GetListeningPid(port) != null;
    }

    private static string GetListeningPid(int port)
    {
        try
        {
            var psi = new ProcessStartInfo();
            psi.FileName        = "netstat.exe";
            psi.Arguments       = "-ano";
            psi.CreateNoWindow  = true;
            psi.UseShellExecute = false;
            psi.WindowStyle     = ProcessWindowStyle.Hidden;
            psi.RedirectStandardOutput = true;
            using (var p = Process.Start(psi))
            {
                string outp = p.StandardOutput.ReadToEnd();
                p.WaitForExit();
                string marker = ":" + port + " ";
                foreach (string line in outp.Split('\n'))
                {
                    if (line.IndexOf(marker, StringComparison.OrdinalIgnoreCase) < 0) continue;
                    if (line.IndexOf("LISTENING", StringComparison.OrdinalIgnoreCase) < 0) continue;
                    var parts = line.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    if (parts.Length >= 5) return parts[4];
                }
            }
        }
        catch { }
        return null;
    }
}

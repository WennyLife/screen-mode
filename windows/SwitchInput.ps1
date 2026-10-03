param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "mac" # "mac" (USB-C = 27), "mac-dp" (DP = 15), "windows" (DP = 15 ou HDMI)
)

$code = @"
using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class MonitorManager {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct PHYSICAL_MONITOR {
        public IntPtr hPhysicalMonitor;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string szPhysicalMonitorDescription;
    }

    private delegate bool MonitorEnumProc(IntPtr hMonitor, IntPtr hdcMonitor, IntPtr lprcMonitor, IntPtr dwData);

    [DllImport("user32.dll")]
    private static extern bool EnumDisplayMonitors(IntPtr hdc, IntPtr lprcClip, MonitorEnumProc lpfnEnum, IntPtr dwData);

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(IntPtr hMonitor, out uint pdwNumberOfPhysicalMonitors);

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool GetPhysicalMonitorsFromHMONITOR(IntPtr hMonitor, uint dwPhysicalMonitorArraySize, [Out] PHYSICAL_MONITOR[] pPhysicalMonitorArray);

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool SetVCPFeature(IntPtr hMonitor, byte bVCPCode, uint dwNewValue);

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool DestroyPhysicalMonitor(IntPtr hMonitor);

    public static void SetInputSource(uint inputSourceCode) {
        List<IntPtr> hMonitors = new List<IntPtr>();
        EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, delegate(IntPtr hMonitor, IntPtr hdcMonitor, IntPtr lprcMonitor, IntPtr dwData) {
            hMonitors.Add(hMonitor);
            return true;
        }, IntPtr.Zero);

        foreach (var hMon in hMonitors) {
            uint count = 0;
            if (GetNumberOfPhysicalMonitorsFromHMONITOR(hMon, out count) && count > 0) {
                PHYSICAL_MONITOR[] phys = new PHYSICAL_MONITOR[count];
                if (GetPhysicalMonitorsFromHMONITOR(hMon, count, phys)) {
                    foreach (var p in phys) {
                        // VCP 0x60 is Input Select:
                        // 15 = DP1, 16 = DP2, 17 = HDMI1, 18 = HDMI2, 27 = USB-C
                        SetVCPFeature(p.hPhysicalMonitor, 0x60, inputSourceCode);
                        DestroyPhysicalMonitor(p.hPhysicalMonitor);
                    }
                }
            }
        }
    }
}
"@

Add-Type -TypeDefinition $code -Language CSharp -IgnoreWarnings

switch ($Target.ToLower()) {
    "mac" {
        # 27 = USB-C (onde o Mac fica via cabo Ugreen 40Gbps)
        [MonitorManager]::SetInputSource(27)
        Write-Host "Monitor alternado para Mac (USB-C 155Hz)"
    }
    "mac-dp" {
        # 15 = DisplayPort 1
        [MonitorManager]::SetInputSource(15)
        Write-Host "Monitor alternado para Mac (DisplayPort 1 155Hz)"
    }
    "windows-dp" {
        # 15 = DisplayPort 1
        [MonitorManager]::SetInputSource(15)
        Write-Host "Monitor alternado para Windows (DisplayPort 1 155Hz)"
    }
    "windows-hdmi1" {
        # 17 = HDMI 1
        [MonitorManager]::SetInputSource(17)
        Write-Host "Monitor alternado para Windows (HDMI 1)"
    }
    "windows-hdmi2" {
        # 18 = HDMI 2
        [MonitorManager]::SetInputSource(18)
        Write-Host "Monitor alternado para Windows (HDMI 2)"
    }
    default {
        # Default Mac USB-C
        [MonitorManager]::SetInputSource(27)
        Write-Host "Monitor alternado para Mac (USB-C 155Hz)"
    }
}

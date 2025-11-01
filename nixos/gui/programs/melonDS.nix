{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  hj.xdg.config.files."melonDS/melonDS.toml" = {
    clobber = true;
    type = "copy";
    permissions = "0644";
    text =
      # toml
      let
        inherit (config.me) user;
      in
      ''
        LastBIOSFolder = ""
        LastROMFolder = "/home/${user}/games/ds/LaytonSpectresCall"
        UITheme = ""
        RecentROM = [
            "/home/${user}/games/ds/LaytonSpectresCall/LaytonSpectresCall.nds",
        ]
        FastForwardFPS = 1000.0
        AudioSync = false
        PauseLostFocus = false
        TargetFPS = 60.0
        LimitFPS = true
        SlowmoFPS = 30.0

        [DS]
        FirmwarePath = ""
        BIOS7Path = ""
        BIOS9Path = ""

        [Audio]
        Interpolation = 0
        BitDepth = 0

        [DLDI]
        FolderPath = ""
        FolderSync = false
        ReadOnly = false
        ImagePath = "dldi.bin"
        ImageSize = 0
        Enable = false

        [Mouse]
        Hide = false
        HideSeconds = 5

        [DSi]
        FullBIOSBoot = false
        FirmwarePath = ""
        BIOS9Path = ""
        BIOS7Path = ""
        NANDPath = ""

        [DSi.SD]
        FolderPath = ""
        FolderSync = false
        ReadOnly = false
        ImagePath = "dsisd.bin"
        ImageSize = 0
        Enable = false

        [DSi.Camera1]
        DeviceName = ""
        ImagePath = ""
        InputType = 0
        XFlip = false

        [DSi.Camera0]
        DeviceName = ""
        ImagePath = ""
        InputType = 0
        XFlip = false

        [3D]
        Renderer = 0

        [3D.Soft]
        Threaded = true

        [MP]
        AudioMode = 1
        RecvTimeout = 25

        [Savestate]
        RelocSRAM = false

        [LAN]
        DirectMode = false

        [Instance0]
        EnableCheats = false
        SaveFilePath = ""
        SavestatePath = ""
        JoystickID = 0
        CheatFilePath = ""

        [Instance0.RTC]
        Offset = 0

        [Instance0.DS]
        [Instance0.DS.Battery]
        LevelOkay = true

        [Instance0.Keyboard]
        HK_SlowMoToggle = -1
        HK_Lid = -1
        Y = -1
        HK_FrameStep = -1
        HK_SolarSensorIncrease = -1
        L = -1
        R = -1
        Up = -1
        HK_FullscreenToggle = 70
        HK_SlowMo = -1
        HK_Pause = 80
        Right = -1
        Start = -1
        Select = -1
        X = -1
        B = -1
        Down = -1
        A = -1
        HK_Mic = -1
        HK_FastForward = -1
        HK_FrameLimitToggle = -1
        Left = -1
        HK_SwapScreens = 83
        HK_SwapScreenEmphasis = -1
        HK_Reset = -1
        HK_PowerButton = -1
        HK_VolumeDown = -1
        HK_SolarSensorDecrease = -1
        HK_VolumeUp = -1
        HK_FastForwardToggle = 84

        [Instance0.Window2]
        Enabled = false

        [Instance0.Joystick]
        HK_SlowMoToggle = -1
        HK_Lid = -1
        Y = -1
        HK_FrameStep = -1
        HK_SolarSensorIncrease = -1
        L = -1
        R = -1
        Up = -1
        HK_FullscreenToggle = -1
        HK_SlowMo = -1
        HK_Pause = -1
        Right = -1
        Start = -1
        Select = -1
        X = -1
        B = -1
        Down = -1
        A = -1
        HK_Mic = -1
        HK_FastForward = -1
        HK_FrameLimitToggle = -1
        Left = -1
        HK_SwapScreens = -1
        HK_SwapScreenEmphasis = -1
        HK_Reset = -1
        HK_PowerButton = -1
        HK_VolumeDown = -1
        HK_SolarSensorDecrease = -1
        HK_VolumeUp = -1
        HK_FastForwardToggle = -1

        [Instance0.Window0]
        ScreenFilter = false
        ScreenAspectTop = 0
        IntegerScaling = false
        ScreenSizing = 0
        ScreenSwap = false
        ScreenGap = 0
        ScreenAspectBot = 0
        ScreenRotation = 0
        ScreenLayout = 3
        Geometry = ""
        ShowOSD = true

        [Instance0.Audio]
        DSiVolumeSync = false
        Volume = 256

        [Instance0.Window3]
        Enabled = false

        [Instance0.Firmware]
        MAC = ""
        Message = ""
        BirthdayDay = 1
        BirthdayMonth = 1
        FavouriteColour = 0
        Language = 1
        Username = "${config.me.user}"

        [Instance0.Window1]
        Enabled = false

        [Instance0.Gdb]
        Enabled = false

        [Instance0.Gdb.ARM9]
        BreakOnStartup = false
        Port = 3333

        [Instance0.Gdb.ARM7]
        BreakOnStartup = false
        Port = 3334

        [Emu]
        DirectBoot = true
        ExternalBIOSEnable = false
        ConsoleType = 0

        [JIT]
        Enable = false
        FastMemory = true
        BranchOptimisations = true
        LiteralOptimisations = true
        MaxBlockSize = 32

        [Screen]
        UseGL = false

        [Mic]
        WavPath = ""
        Device = ""
        InputType = 1
      '';
  };
}

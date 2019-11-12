codeunit 50100 "PublishBCAppFile"
{
    procedure ImportAppFileAndPublish()
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Powershellrunner: DotNet PowerShellRunner;
    begin
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, 'Select App File', '', FileFilter, AllFilesFilterTxt);

        if FileName = '' then begin
            Error(CancelledErr);
        end;

        FileName := TemporaryPath + FileName;

        if Exists(FileName) then begin
            Erase(FileName);
        end;

        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        CreatePowerShellRunnerAndImportModule(Powershellrunner, PublishAppCmd, PathTxt, SkipVerificationTxt, FileName, '');
        PowerShellCmdInvoke(Powershellrunner, BusyDlg);
    end;

    procedure UnPublishBCApp(var NAVApp: Record "NAV App")
    var
        ExtensionMgt: Codeunit "Extension Management";
        Powershellrunner: DotNet PowerShellRunner;
    begin
        if not Confirm(StrSubstNo(UnPublishConfirmation, NAVApp.Name), false) then
            Error(CancelledErr);

        AppVersionTxt := StrSubstNo(SelectedAppVersion, NAVApp."Version Major", NAVApp."Version Minor", NAVApp."Version Build", NAVApp."Version Revision");

        if ExtensionMgt.IsInstalledByPackageId(NAVApp."Package ID") then begin
            CreatePowerShellRunnerAndImportModule(Powershellrunner, UninstallAppCmd, NameTxt, VersionTxt, NAVApp.Name, AppVersionTxt);
            PowerShellCmdInvoke(Powershellrunner, UninstallDlg);
        end;

        CreatePowerShellRunnerAndImportModule(Powershellrunner, UnPublishAppCmd, NameTxt, VersionTxt, NAVApp.Name, AppVersionTxt);
        PowerShellCmdInvoke(Powershellrunner, UnpublishDlg);
    end;

    local procedure CreatePowerShellRunnerAndImportModule(var Powershellrunner: DotNet PowerShellRunner; Command: Text; ParmName1: Text; ParmName2: Text; Parm1: Text; Parm2: Text)
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.Get(ServiceInstanceId(), SessionId());

        PowerShellRunner := PowerShellRunner.CreateInSandbox();
        PowerShellRunner.WriteEventOnError := true;
        PowerShellRunner.ImportModule(ApplicationPath + NAVAdminTool);
        PowerShellRunner.AddCommand(Command);
        Powershellrunner.AddParameter(ServerInstanceTxt, ActiveSession."Server Instance Name");
        Powershellrunner.AddParameter(ParmName1, Parm1);
        if Parm2 = '' then
            PowerShellRunner.AddParameter(ParmName2)
        else
            PowerShellRunner.AddParameter(ParmName2, Parm2);
    end;

    local procedure PowerShellCmdInvoke(var Powershellrunner: DotNet PowerShellRunner; DiagTxt: Text)
    var
        Window: Dialog;
    begin
        Window.Open(DiagTxt);

        PowerShellRunner.BeginInvoke;

        while not PowerShellRunner.IsCompleted do
            Sleep(1000);

        Window.Close();
    end;

    var
        AppVersionTxt: Text;
        AllFilesFilterTxt: Label '*.*';
        BusyDlg: Label 'Busy publishing app......';
        CancelledErr: Label 'Operation cancelled by user.';
        FileFilter: Label 'App (*.app)|*.app|All Files (*.*)|*.*';
        NameTxt: Label 'Name';
        NAVAdminTool: Label 'NavAdminTool.ps1';
        PathTxt: Label 'Path';
        PublishAppCmd: Label 'Publish-NAVApp';
        SelectedAppVersion: Label '%1.%2.%3.%4';
        ServerInstanceTxt: Label 'ServerInstance';
        SkipVerificationTxt: Label 'SkipVerification';
        UninstallAppCmd: Label 'Uninstall-NAVApp';
        UninstallDlg: Label 'Uninstalling app......';
        UnPublishAppCmd: Label 'Unpublish-NAVApp';
        UnPublishConfirmation: Label 'Are you sure that you want to Unpublish "%1"?';
        UnpublishDlg: Label 'Unpublishing app......';
        VersionTxt: Label 'Version';
}
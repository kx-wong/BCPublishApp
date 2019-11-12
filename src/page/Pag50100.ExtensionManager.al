page 50100 "Extension Manager"
{
    PageType = List;
    SourceTable = "NAV App";
    Caption = 'Extension Manager';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTableView = sorting(Name) order(Ascending) where(Name = filter(<> ' _Exclude_*'), "Package Type" = filter(= 0 | 2), Publisher = filter(<> 'Microsoft'));
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Publisher; Publisher)
                {

                }
                field(AppVersion; StrSubstNo(VersionTxt, "Version Major", "Version Minor", "Version Build", "Version Revision"))
                {
                    Caption = 'Version';
                }
                field(CurrStatus; AppStatus)
                {
                    Caption = 'Status';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Manage)
            {
                Action(PublishApp)
                {
                    ApplicationArea = All;
                    Caption = 'Publish';
                    Image = ImportCodes;
                    trigger OnAction()
                    var
                        ImportBCAppFile: Codeunit "PublishBCAppFile";
                    begin
                        ImportBCAppFile.ImportAppFileAndPublish();
                        CurrPage.Update(false);
                    end;
                }
                Action(UnPublishApp)
                {
                    ApplicationArea = All;
                    Caption = 'Unpublish';
                    Image = RemoveLine;
                    trigger OnAction()
                    var
                        ImportBCAppFile: Codeunit "PublishBCAppFile";
                    begin
                        ImportBCAppFile.UnPublishBCApp(Rec);
                        CurrPage.Update(false);
                    end;
                }
                Action(InstallUninstallApp)
                {
                    ApplicationArea = All;
                    Caption = 'Install/Uninstall';
                    Image = Approve;
                    trigger OnAction()
                    begin
                        InstallOrUninstall();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatus();
    end;

    local procedure InstallOrUninstall()
    var
        ExtensionDetails: Page "Extension Details";
    begin
        ExtensionDetails.SetRecord(Rec);
        ExtensionDetails.RunModal();

        UpdateStatus();

        CurrPage.Update(false);
    end;

    local procedure UpdateStatus()
    begin
        if ExtensionManagement.IsInstalledByPackageId("Package ID") then begin
            AppStatus := InstallTxt;
        end else begin
            AppStatus := PublishTxt;
        end;
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";
        Language: Codeunit Language;
        AppStatus: Text[30];
        InstallTxt: Label 'Installed';
        PublishTxt: Label 'Published';
        VersionTxt: Label '%1.%2.%3.%4';
}

// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!
tableextension 50141 timesheetLineExt extends "Time Sheet Line"
{
    fields
    {

        field(50101; Comments; Text[2000])
        {
            Caption = 'Comment';

        }
    }
}
pageextension 50142 TimeSheetExt extends "Time Sheet"
{
    layout
    {
        addlast(Control1)
        {
            field("Comments"; Rec.Comments)
            {
                Caption = 'Comment';
                ApplicationArea = ALL;
                Visible = true;

            }
        }
    }
    // var
    //     isCronusCompany: Boolean;

    // trigger OnOpenPage()

    // begin


    //     isCronusCompany := false;

    //     if (CompanyName() = 'zzz_CRONUS USA, Inc.') OR (CompanyName() = 'CRONUS USA, Inc.')

    //      then begin
    //         isCronusCompany := true;

    //     end;

    // end;
}

pageextension 50143 ManagerTimeSheetExt extends "Manager Time Sheet"
{
    layout
    {
        addlast(Control1)
        {
            field("Comments"; Rec.Comments)
            {
                Caption = 'Comment';
                ApplicationArea = ALL;
                Visible = true;

            }
        }
    }
    // var
    //     isCronusCompany: Boolean;

    // trigger OnOpenPage()

    // begin


    //     isCronusCompany := false;

    //     if (CompanyName() = 'zzz_CRONUS USA, Inc.') OR (CompanyName() = 'CRONUS USA, Inc.')

    //     then begin
    //         isCronusCompany := true;

    //     end;

    // end;
}


tableextension 50147 JobJournalLineExt extends "Job Journal Line"
{
    fields
    {

        field(50101; Comments; Text[2000])
        {
            Editable = false;
            Caption = 'Comment';
            FieldClass = FlowField;
            CalcFormula = lookup("Time Sheet Line".Comments WHERE("Job No." = field("Job No."), "Line No." = field("Time Sheet Line No."), "Time Sheet No." = field("Time Sheet No.")));

        }
    }
}

pageextension 50148 JobJournalExt extends "Job Journal"
{


    layout
    {
        addlast(Control1)
        {
            field("TimeSheetComment"; Rec.Comments)
            {
                Editable = false;
                Caption = 'Comment';
                ApplicationArea = ALL;

            }
        }
    }
    actions
    {
        modify("P&ost")
        {
            Visible = false;

        }
        addafter("P&ost")
        {
            action(Post)
            {

                ApplicationArea = Jobs;
                Caption = 'P&ost';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                trigger OnAction()
                begin

                    temprec.DeleteAll();
                    if Rec.FindSet() then
                        repeat

                            temprec."Job No." := Rec."Job No.";
                            temprec.Comments := Rec.Comments;
                            temprec."Job Task No." := Rec."Job Task No.";
                            temprec.DocNumber := Rec."Document No.";
                            temprec.Insert();

                        until (Rec.Next() = 0);

                    CODEUNIT.Run(CODEUNIT::"Job Jnl.-Post", Rec);
                    CODEUNIT.Run(CODEUNIT::ModifyJobJnlEntries);
                    CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                    CurrPage.Update(false);

                end;
            }
        }
    }
    var
        CurrentJnlBatchName: Code[10];
        JobJnlManagement: Codeunit JobJnlManagement;


    var
        temprec: Record TempTable;

    var
        JobJnlEntries: Record "Job Ledger Entry";

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        JobJnlManagement.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure OpenJournal()
    var
        JnlSelected: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenJournal(Rec, JobJnlManagement, CurrentJnlBatchName, IsHandled);
        if IsHandled then
            exit;

        if Rec.IsOpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            JobJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        JobJnlManagement.TemplateSelection(PAGE::"Job Journal", false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        JobJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
    end;




    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenJournal(var JobJournalLine: Record "Job Journal Line"; var JobJnlManagement: Codeunit JobJnlManagement; CurrentJnlBatchName: Code[10]; var IsHandled: Boolean)
    begin
    end;

}
codeunit 50144 ModifyJobJnlEntries
{
    Permissions = tabledata "Job Ledger Entry" = rmd;

    trigger OnRun()
    var

        temprec: Record TempTable;
        JobJnlEntries: Record "Job Ledger Entry";
    begin
        if temprec.FindSet() then
            repeat
                JobJnlEntries.SetFilter("Document No.", temprec.DocNumber);
                JobJnlEntries.SetFilter("Job No.", temprec."Job No.");
                JobJnlEntries.SetFilter("Job Task No.", temprec."Job Task No.");
                if JobJnlEntries.FindFirst() then begin
                    JobJnlEntries.Comments := temprec.Comments;
                    JobJnlEntries.Modify();

                end;
            until (temprec.Next() = 0);
    end;
}
tableextension 50100 JobLedgerEntryExt extends "Job Ledger Entry"
{

    fields
    {

        field(50101; Comments; Text[2000])
        {
            Caption = 'Comment';
            Editable = true;
        }
    }
}
pageextension 50139 JobLedgerEntriesExt extends "Job Ledger Entries"
{
    layout
    {

        addlast(Control1)
        {
            field("TimeSheetComment"; Rec.Comments)
            {
                Editable = true;
                Caption = 'Comment';
                ApplicationArea = ALL;

            }
        }
    }


}

table 50100 TempTable
{
    DataClassification = ToBeClassified;
    fields
    {

        field(50101; "DocNumber"; Code[20])
        {

        }

        field(50102; "Job No."; Code[20])
        {

        }
        field(50103; "Job Task No."; Code[20])
        {

        }
        field(50104; Comments; Text[2000])
        {


        }
    }
}

page 50149 TempTable
{
    Caption = 'Temp Table';
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'temp, table, temptable, temp table';
    PageType = List;
    SourceTable = TempTable;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(DocNumber; Rec.DocNumber)
                {
                    ApplicationArea = all;
                }

                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = all;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = all;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = all;
                }


            }
        }
    }
}

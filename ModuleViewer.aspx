<%@ Page Title="Module" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ModuleViewer.aspx.cs" Inherits="Atelier.ModuleViewer" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
            <div class="alert alert-danger">Module not found.</div>
        </asp:Panel>
        

        <asp:Panel ID="pnlNotEnrolled" 

    runat="server" 
    Visible="false">
    <div style="text-align:center;
                padding:60px 40px;
                background:#FEF3C7;
                border:0.5px solid #FDE68A;
                border-radius:16px;
                margin:40px auto;
                max-width:600px">
        <h2 style="color:#92400E;
                   margin-bottom:12px">
            Members Only Content
        </h2>
        <p style="color:#92400E;
                  margin-bottom:24px">
            This module is only available 
            to enrolled learners. Please 
            sign in and enrol in this course 
            to access the full content.
        </p>
        <div style="display:flex;
                    gap:12px;
                    justify-content:center">
            <a href="~/Login.aspx" 
               runat="server"
               class="btn btn-primary"
               style="color:#BFCFE8 !important;
                      background-color:#6B1A2A !important;">
                Sign In
            </a>
            <a href="~/Register.aspx" 
               runat="server"
               class="btn btn-secondary">
                Register
            </a>
        </div>
    </div>
            </asp:Panel>

        <asp:Panel ID="pnlAccessDenied" runat="server" Visible="false" CssClass="card" style="margin-top:24px;text-align:center;padding:40px 20px">
            <div style="margin-bottom:16px;display:flex;justify-content:center;align-items:center;">
                <div style="width:64px;height:64px;border-radius:50%;background:rgba(107,26,42,0.1);display:flex;align-items:center;justify-content:center;">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#6B1A2A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                </div>
            </div>
            <h3>Module Locked</h3>
            <p style="color:var(--muted-colour);margin-bottom:24px;font-size:16px">
                Please login or enroll to access this module.
            </p>
            <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
                <asp:HyperLink ID="lnkRegisterAccess" runat="server" CssClass="btn btn-primary" Text="Register Account" style="color:#BFCFE8 !important;background-color:#6B1A2A !important;" />
                <asp:HyperLink ID="lnkLoginAccess" runat="server" CssClass="btn btn-secondary" Text="Log In" style="color:#6B1A2A !important;border:1.5px solid #6B1A2A !important;" />
                <asp:Button ID="btnEnrollAccess" runat="server" CssClass="btn btn-primary" Text="Enroll in Course" Visible="false" OnClick="btnEnrollAccess_Click" style="color:#BFCFE8 !important;background-color:#6B1A2A !important;" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlModule" runat="server">

            <p class="course-meta">
                <asp:HyperLink ID="lnkBackToCourse" runat="server" Text="&larr; Back to course" />
            </p>

            <h1><asp:Literal ID="litTitle" runat="server" /></h1>
            <p class="course-meta">
                <asp:Literal ID="litDuration" runat="server" /> mins
                &nbsp;&middot;&nbsp;
                <asp:Literal ID="litType" runat="server" />
            </p>

            <asp:Panel ID="pnlModuleContent" runat="server">

                <div style="margin:24px 0">
                    <asp:Literal ID="litDescription" runat="server" />
                </div>

                <asp:Panel ID="pnlVideo" runat="server" Visible="false" 
                           style="margin:24px 0;text-align:center">
                    <asp:Literal ID="litVideo" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlPdf" runat="server" Visible="false" CssClass="card">
                    <h4>Course Material</h4>
                    <p class="course-meta">This module is delivered as a PDF document.</p>
                    <asp:HyperLink ID="lnkPdf" runat="server"
                        CssClass="btn btn-primary btn-sm"
                        Target="_blank"
                        Text="Open PDF"
                        style="color:#BFCFE8 !important;background-color:#6B1A2A !important;" />
                </asp:Panel>

                <div class="card" style="margin-top:24px">
                    <asp:Panel ID="pnlCompleted" runat="server" Visible="false">
                        <span class="badge badge-success">Completed</span>
                        <p class="course-meta" style="margin-top:8px">
                            You finished this module on
                            <asp:Literal ID="litCompletedAt" runat="server" />.
                        </p>
                    </asp:Panel>

                    <asp:Panel ID="pnlNotCompleted" runat="server">
                        <p>Finished with this module?</p>
                        <asp:Button ID="btnComplete" runat="server"
                            Text="Mark as Complete"
                            CssClass="btn btn-primary"
                            OnClick="btnComplete_Click" />
                    </asp:Panel>
                </div>

                <div class="card" style="margin-top:24px">
                    <h4>My Notes</h4>
                    <p class="course-meta">Only you can see these.</p>

                    <asp:Panel ID="pnlNoteSaved" runat="server" Visible="false">
                        <div class="alert alert-success">Notes saved.</div>
                    </asp:Panel>

                    <div class="form-group">
                        <asp:TextBox ID="txtNotes" runat="server"
                            TextMode="MultiLine"
                            Rows="6"
                            placeholder="Write your notes here..." />
                    </div>

                    <asp:RequiredFieldValidator ID="rfvNotes" runat="server"
                        ControlToValidate="txtNotes"
                        ErrorMessage="Please write something before saving."
                        ValidationGroup="Notes"
                        CssClass="alert alert-danger"
                        Display="Dynamic" />

                    <asp:Button ID="btnSaveNotes" runat="server"
                        Text="Save Notes"
                        CssClass="btn btn-secondary"
                        ValidationGroup="Notes"
                        OnClick="btnSaveNotes_Click" />

                    <p class="course-meta" style="margin-top:8px">
                        <asp:Literal ID="litNoteUpdated" runat="server" />
                    </p>
                </div>

            </asp:Panel>

        </asp:Panel>

    </div>

</asp:Content>
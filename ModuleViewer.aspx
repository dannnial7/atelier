<%@ Page Title="Module" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ModuleViewer.aspx.cs" Inherits="Atelier.ModuleViewer" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div id="divCourseBg" runat="server" class="course-bg-backdrop" style="position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:-1;background-size:cover;background-position:center;background-repeat:no-repeat;opacity:0.65;pointer-events:none;filter:brightness(0.85) blur(2px);"></div>

    <div class="container" style="margin-top:40px">

        <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
            <div class="alert alert-danger">Module not found.</div>
        </asp:Panel>

        <asp:Panel ID="pnlAccessDenied" runat="server" Visible="false" CssClass="card" style="margin-top:24px;text-align:center;padding:40px 20px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
            <div style="margin-bottom:16px;display:flex;justify-content:center;align-items:center;">
                <div style="width:64px;height:64px;border-radius:50%;background:rgba(107,26,42,0.1);display:flex;align-items:center;justify-content:center;">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#6B1A2A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                </div>
            </div>
            <h3 style="color:#0f172a;">Module Locked</h3>
            <p style="color:#64748b;margin-bottom:24px;font-size:16px">
                Please login or enroll to access this module.
            </p>
            <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
                <asp:HyperLink ID="lnkRegisterAccess" runat="server" CssClass="btn btn-primary" Text="Register Account" style="color:#BFCFE8 !important;background-color:#6B1A2A !important;" />
                <asp:HyperLink ID="lnkLoginAccess" runat="server" CssClass="btn btn-secondary" Text="Log In" style="color:#6B1A2A !important;border:1.5px solid #6B1A2A !important;" />
                <asp:Button ID="btnEnrollAccess" runat="server" CssClass="btn btn-primary" Text="Enroll in Course" Visible="false" OnClick="btnEnrollAccess_Click" style="color:#BFCFE8 !important;background-color:#6B1A2A !important;" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlModule" runat="server">

            <%-- Module Header Solid Card --%>
            <div class="card" style="margin-bottom:24px;padding:32px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                <p class="course-meta" style="margin-bottom:12px;">
                    <asp:HyperLink ID="lnkBackToCourse" runat="server" Text="&larr; Back to course" style="font-weight:600;color:#6B1A2A;" />
                </p>

                <h1 style="margin-top:0;font-size:30px;color:#0f172a;"><asp:Literal ID="litTitle" runat="server" /></h1>
                <p class="course-meta" style="margin-top:6px;font-size:15px;color:#64748b;">
                    <asp:Literal ID="litDuration" runat="server" /> mins
                    &nbsp;&middot;&nbsp;
                    <asp:Literal ID="litType" runat="server" />
                </p>
            </div>

            <asp:Panel ID="pnlModuleContent" runat="server">

                <div class="card" style="margin-bottom:24px;padding:32px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                    <h4 style="margin-top:0;margin-bottom:16px;color:#0f172a;">Module Overview & Material Description</h4>
                    <div style="font-size:16px;line-height:1.7;color:#334155;">
                        <asp:Literal ID="litDescription" runat="server" />
                    </div>
                </div>

                <asp:Panel ID="pnlVideo" runat="server" Visible="false" 
                           style="margin:24px 0;text-align:center">
                    <asp:Literal ID="litVideo" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlPdf" runat="server" Visible="false" CssClass="card" style="padding:32px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                    <h4 style="color:#0f172a;">Course Document</h4>
                    <p class="course-meta" style="color:#64748b;">This module is delivered as a PDF document.</p>
                    <asp:HyperLink ID="lnkPdf" runat="server"
                        CssClass="btn btn-primary btn-sm"
                        Target="_blank"
                        Text="Open PDF"
                        style="color:#BFCFE8 !important;background-color:#6B1A2A !important;padding:8px 20px;font-weight:600;" />
                </asp:Panel>

                <div class="card" style="margin-top:24px;padding:32px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                    <asp:Panel ID="pnlCompleted" runat="server" Visible="false">
                        <span class="badge badge-success">Completed</span>
                        <p class="course-meta" style="margin-top:8px;color:#64748b;">
                            You finished this module on
                            <asp:Literal ID="litCompletedAt" runat="server" />.
                        </p>
                    </asp:Panel>

                    <asp:Panel ID="pnlNotCompleted" runat="server">
                        <p style="font-size:16px;font-weight:600;color:#0f172a;">Finished with this module?</p>
                        <asp:Button ID="btnComplete" runat="server"
                            Text="Mark as Complete"
                            CssClass="btn btn-primary"
                            OnClick="btnComplete_Click"
                            style="color:#BFCFE8 !important;background-color:#6B1A2A !important;padding:10px 24px;font-weight:600;" />
                    </asp:Panel>
                </div>

                <div class="card" style="margin-top:24px;padding:32px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                    <h4 style="margin-top:0;color:#0f172a;">My Notes</h4>
                    <p class="course-meta" style="color:#64748b;">Only you can see these.</p>

                    <asp:Panel ID="pnlNoteSaved" runat="server" Visible="false">
                        <div class="alert alert-success">Notes saved.</div>
                    </asp:Panel>

                    <div class="form-group" style="margin-top:16px;">
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
                        OnClick="btnSaveNotes_Click"
                        style="padding:8px 20px;font-weight:600;" />

                    <p class="course-meta" style="margin-top:8px;color:#64748b;">
                        <asp:Literal ID="litNoteUpdated" runat="server" />
                    </p>
                </div>

            </asp:Panel>

        </asp:Panel>

    </div>

</asp:Content>
<%@ Page Title="Course Detail" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseDetail.aspx.cs" Inherits="Atelier.CourseDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div id="divCourseBg" runat="server" class="course-bg-backdrop" style="position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:-1;background-size:cover;background-position:center;background-repeat:no-repeat;opacity:0.65;pointer-events:none;filter:brightness(0.85) blur(2px);"></div>

    <div class="container" style="margin-top:40px">

        <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
            <div class="alert alert-danger">
                Course not found. <a href="~/Courses.aspx" runat="server">Back to catalogue</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlCourse" runat="server">

            <%-- Course Header Solid Card --%>
            <div class="card" style="margin-bottom:28px;padding:36px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                <h1 style="margin-top:0;font-size:32px;font-weight:700;color:#0f172a;"><asp:Literal ID="litTitle" runat="server" /></h1>
                <p class="course-meta" style="margin-top:8px;font-size:15px;color:#64748b;">
                    <asp:Literal ID="litCategory" runat="server" /> &nbsp;&middot;&nbsp;
                    <asp:Literal ID="litDifficulty" runat="server" />
                </p>
                <p style="margin-top:16px;font-size:16px;line-height:1.6;color:#334155;"><asp:Literal ID="litDescription" runat="server" /></p>

                <asp:Panel ID="pnlEnroll" runat="server" style="margin-top:24px">
                    <asp:Button ID="btnEnrollCourse" runat="server"
                        CssClass="btn btn-primary btn-lg"
                        style="color:#BFCFE8 !important;background-color:#6B1A2A !important;border:none !important;padding:12px 28px;font-weight:600;"
                        OnClick="btnEnrollCourse_Click" />
                </asp:Panel>

                <asp:Panel ID="pnlProgress" runat="server" Visible="false" style="margin-top:24px">
                    <h4 style="color:#0f172a;">Your Progress</h4>
                    <div class="progress" style="margin:10px 0;height:12px;background:#e2e8f0;border-radius:6px;">
                        <div id="divProgressFill" runat="server" class="progress-fill" style="height:100%;background:#059669;border-radius:6px;"></div>
                    </div>
                    <p class="course-meta" style="color:#475569;"><asp:Literal ID="litProgress" runat="server" />% complete</p>

                    <asp:HyperLink ID="lnkViewCertificate" runat="server"
                        CssClass="btn btn-primary"
                        style="margin-top:14px;display:inline-flex;align-items:center;gap:8px;color:#BFCFE8 !important;background-color:#6B1A2A !important;font-weight:600;padding:10px 22px;"
                        Visible="false">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                            <polyline points="14 2 14 8 20 8"></polyline>
                            <line x1="16" y1="13" x2="8" y2="13"></line>
                            <line x1="16" y1="17" x2="8" y2="17"></line>
                        </svg>
                        View Certificate of Completion
                    </asp:HyperLink>
                </asp:Panel>
            </div>

            <%-- Modules Section Solid Card --%>
            <div class="card" style="padding:36px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                <h2 class="section-title" style="margin-top:0;margin-bottom:24px;font-size:24px;color:#0f172a;">Course Modules & Materials</h2>

                <asp:Repeater ID="rptModules" runat="server">
                    <ItemTemplate>
                        <div class="card-sm" style="margin-bottom:16px;background:#f8fafc !important;border:1px solid #e2e8f0;padding:20px 24px;border-radius:12px;">
                            <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:16px;">
                                <div style="flex:1;">
                                    <strong style="font-size:17px;color:#0f172a;"><%# Eval("OrderIndex") %>. <%# Eval("Title") %></strong>
                                    <p class="course-meta" style="margin-top:6px;font-size:14px;color:#64748b;">
                                        <%# FormatContentType(Eval("ContentType")) %> &nbsp;&middot;&nbsp;
                                        <%# Eval("DurationMins") %> mins
                                        <%# FormatModuleBadge(Eval("IsCompleted"), Eval("IsPreview")) %>
                                    </p>
                                    <p style="margin-top:10px;font-size:14px;color:#334155;line-height:1.55;margin-bottom:0;">
                                        <%# Eval("Description") %>
                                    </p>
                                </div>
                                <a href='<%# "~/ModuleViewer.aspx?id=" + Eval("ModuleID") %>'
                                   runat="server"
                                   class="btn btn-primary btn-sm"
                                   style="color:#BFCFE8 !important;background-color:#6B1A2A !important;padding:8px 22px;font-weight:600;white-space:nowrap;margin-top:4px;">
                                    Open
                                </a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <%-- Assessment Quiz Section Solid Card --%>
            <asp:Panel ID="pnlAssessmentSection" runat="server" Visible="false" class="card" style="margin-top:24px;padding:36px;background:#ffffff !important;box-shadow:0 12px 36px rgba(0,0,0,0.16);border-radius:16px;border:1px solid #e2e8f0;">
                <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px;">
                    <div>
                        <h2 class="section-title" style="margin:0;font-size:24px;color:#0f172a;">Course Assessment Quiz</h2>
                        <p style="margin-top:6px;font-size:15px;color:#475569;margin-bottom:0;">
                            <asp:Literal ID="litAssessmentTitle" runat="server" /> &nbsp;&middot;&nbsp; Pass mark: <strong><asp:Literal ID="litAssessmentPassMark" runat="server" />%</strong>
                        </p>
                    </div>
                    <div>
                        <asp:HyperLink ID="lnkTakeAssessment" runat="server"
                            CssClass="btn btn-primary"
                            style="color:#BFCFE8 !important;background-color:#6B1A2A !important;padding:10px 24px;font-weight:600;display:inline-block;"
                            Text="Take Quiz Assessment" />
                        <asp:HyperLink ID="lnkViewQuizResults" runat="server"
                            CssClass="btn btn-secondary"
                            style="padding:10px 20px;font-weight:600;display:inline-block;margin-left:8px;"
                            Text="View Quiz Results"
                            Visible="false" />
                    </div>
                </div>
            </asp:Panel>

        </asp:Panel>

    </div>

</asp:Content>
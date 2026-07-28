<%@ Page Title="Course Detail" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseDetail.aspx.cs" Inherits="Atelier.CourseDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div id="divCourseBg" runat="server" class="course-bg-backdrop" style="position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:-1;background-size:cover;background-position:center;opacity:0.50;pointer-events:none;filter:brightness(0.7) blur(2px);"></div>

    <div class="container" style="margin-top:40px">

        <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
            <div class="alert alert-danger">
                Course not found. <a href="~/Courses.aspx" runat="server">Back to catalogue</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlCourse" runat="server">

            <%-- Course Header Solid Card --%>
            <div class="card" style="margin-bottom:24px;padding:36px;background:var(--card-bg, #ffffff);box-shadow:0 10px 30px rgba(0,0,0,0.12);border-radius:16px;border:1px solid rgba(255,255,255,0.2);">
                <h1 style="margin-top:0;font-size:32px;font-weight:700;"><asp:Literal ID="litTitle" runat="server" /></h1>
                <p class="course-meta" style="margin-top:8px;font-size:15px;">
                    <asp:Literal ID="litCategory" runat="server" /> &nbsp;&middot;&nbsp;
                    <asp:Literal ID="litDifficulty" runat="server" />
                </p>
                <p style="margin-top:16px;font-size:16px;line-height:1.6;"><asp:Literal ID="litDescription" runat="server" /></p>

                <asp:Panel ID="pnlEnroll" runat="server" style="margin-top:24px">
                    <asp:Button ID="btnEnrollCourse" runat="server"
                        CssClass="btn btn-primary btn-lg"
                        style="color:#BFCFE8 !important;background-color:#6B1A2A !important;border:none !important;padding:12px 28px;font-weight:600;"
                        OnClick="btnEnrollCourse_Click" />
                </asp:Panel>

                <asp:Panel ID="pnlProgress" runat="server" Visible="false" style="margin-top:24px">
                    <h4>Your Progress</h4>
                    <div class="progress" style="margin:10px 0;height:12px;background:#e2e8f0;border-radius:6px;">
                        <div id="divProgressFill" runat="server" class="progress-fill" style="height:100%;background:#059669;border-radius:6px;"></div>
                    </div>
                    <p class="course-meta"><asp:Literal ID="litProgress" runat="server" />% complete</p>
                </asp:Panel>
            </div>

            <%-- Modules Section Solid Card --%>
            <div class="card" style="padding:36px;background:var(--card-bg, #ffffff);box-shadow:0 10px 30px rgba(0,0,0,0.12);border-radius:16px;border:1px solid rgba(255,255,255,0.2);">
                <h2 class="section-title" style="margin-top:0;margin-bottom:24px;font-size:24px;">Modules</h2>

                <asp:Repeater ID="rptModules" runat="server">
                    <ItemTemplate>
                        <div class="card-sm" style="margin-bottom:14px;background:var(--card-bg-subtle, #f8fafc);border:1px solid rgba(0,0,0,0.08);padding:18px 22px;border-radius:12px;">
                            <div style="display:flex;justify-content:space-between;align-items:center">
                                <div>
                                    <strong style="font-size:16px;"><%# Eval("OrderIndex") %>. <%# Eval("Title") %></strong>
                                    <p class="course-meta" style="margin-top:6px;font-size:14px;">
                                        <%# FormatContentType(Eval("ContentType")) %> &nbsp;&middot;&nbsp;
                                        <%# Eval("DurationMins") %> mins
                                        <%# FormatModuleBadge(Eval("IsCompleted"), Eval("IsPreview")) %>
                                    </p>
                                </div>
                                <a href='<%# "~/ModuleViewer.aspx?id=" + Eval("ModuleID") %>'
                                   runat="server"
                                   class="btn btn-primary btn-sm"
                                   style="color:#BFCFE8 !important;background-color:#6B1A2A !important;padding:8px 20px;font-weight:600;">
                                    Open
                                </a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </asp:Panel>

    </div>

</asp:Content>
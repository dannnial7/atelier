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

            <h1><asp:Literal ID="litTitle" runat="server" /></h1>
            <p class="course-meta">
                <asp:Literal ID="litCategory" runat="server" /> &nbsp;&middot;&nbsp;
                <asp:Literal ID="litDifficulty" runat="server" />
            </p>
            <p style="margin-top:16px"><asp:Literal ID="litDescription" runat="server" /></p>

            <asp:Panel ID="pnlEnroll" runat="server" style="margin:20px 0">
                <asp:Button ID="btnEnrollCourse" runat="server"
                    CssClass="btn btn-primary btn-lg"
                    style="color:#BFCFE8 !important;background-color:#6B1A2A !important;border:none !important;"
                    OnClick="btnEnrollCourse_Click" />
            </asp:Panel>

            <asp:Panel ID="pnlProgress" runat="server" Visible="false" CssClass="card">
                <h4>Your Progress</h4>
                <div class="progress" style="margin:10px 0">
                    <div id="divProgressFill" runat="server" class="progress-fill"></div>
                </div>
                <p class="course-meta"><asp:Literal ID="litProgress" runat="server" />% complete</p>
            </asp:Panel>

            <h2 class="section-title" style="margin-top:32px">Modules</h2>

            <asp:Repeater ID="rptModules" runat="server">
                <ItemTemplate>
                    <div class="card-sm" style="margin-bottom:12px">
                        <div style="display:flex;justify-content:space-between;align-items:center">
                            <div>
                                <strong><%# Eval("OrderIndex") %>. <%# Eval("Title") %></strong>
                                <p class="course-meta">
                                    <%# FormatContentType(Eval("ContentType")) %> &nbsp;&middot;&nbsp;
                                    <%# Eval("DurationMins") %> mins
                                    <%# FormatModuleBadge(Eval("IsCompleted"), Eval("IsPreview")) %>
                                </p>
                            </div>
                            <a href='<%# "~/ModuleViewer.aspx?id=" + Eval("ModuleID") %>'
                               runat="server"
                               class="btn btn-primary btn-sm"
                               style="color:#BFCFE8 !important;background-color:#6B1A2A !important;">
                                Open
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </asp:Panel>

    </div>

</asp:Content>
<%@ Page Title="Courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="Atelier.Courses" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <h1>Course Catalogue</h1>
        <p style="color:var(--muted-colour);margin-bottom:32px">
            Browse all available courses across our creative disciplines.
        </p>

        <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
            <div class="alert alert-info">
                No courses are available at the moment. Please check back later.
            </div>
        </asp:Panel>

        <div class="grid-courses">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card">
                        <asp:Image runat="server" CssClass="course-thumbnail"
                            ImageUrl='<%# Eval("Thumbnail") %>'
                            AlternateText='<%# Eval("Title") %>' />
                        <div class="course-body">
                            <p class="course-title">
                                <%# Eval("Title") %>
                            </p>
                            <p class="course-meta">
                                <%# Eval("CategoryName") %>
                                &nbsp;&middot;&nbsp;
                                <%# Eval("Difficulty") %>
                            </p>
                            <p class="course-price">
                                RM <%# Eval("Price", "{0:F2}") %>
                            </p>
                            <a href='<%# "CourseDetail.aspx?id=" + Eval("CourseID") %>'
                               class="btn btn-primary btn-sm"
                               style="margin-top:8px;
                                      display:block;
                                      text-align:center;
                                      color:#BFCFE8 !important;
                                      background-color:#6B1A2A !important;">
                                View Course
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </div>

</asp:Content>

<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Atelier._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"> </asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    
            <div id="hero">
                <h1> One Platform. Endless Creativity.</h1>
                <p>Master Visual Arts, Digital Art, Phototgraphy, Film & Video and Music at your own pace.</p>
                <div style="display:flex;gap:12px; justify-content:center; margin-top:20px">
                    <a href="~/Courses.aspx" runat="server" class="btn btn-secondary" style="color:#6B1A2A !important; border:1.5px solid #6B1A2A !important; background:transparent !important;"> Browse Courses </a>
                    <a href="~/Register.aspx" runat="server" class="btn btn-secondary"> Join to be part of the community! </a>
                </div>

            </div>
    <div class="container">
        <div class="grid-stats" style="margin:40px 0"> 
            <div class="stat-card"> <div class="stat-number">6</div>
                <div class="stat-label"> Creative Disciplines</div>
            </div>
            <div class="stat-card">  <asp:Label ID="lblUserCount" runat="server" CssClass="stat-number" Text="0"/>
                <div class="stat-label">
                    Learners Enrolled
                    </div>
                  </div>
            <div class="stat-card">
                <div class="stat-number">100%</div>
                <div class="stat-label">
                    Free to Browse
                </div>
            </div>
        </div>

        <h2 class="section-title">
            Featured Courses
        </h2>

        <div class="grid-courses">
            <asp:Repeater ID="rptCourses" runat="server"> <ItemTemplate>
                    <div class="course-card">
                        <asp:Image runat="server" CssClass="course-thumbnail" ImageUrl='<%# Eval("Thumbnail") %>' 
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

    <%-- About section --%>

    <div style="background-color:#F0F4F9;
            padding:60px 40px;
            text-align:center;
            margin-top:40px">
    <h2>Why Choose Atelier?</h2>
    <p style="max-width:600px;
              margin:16px auto;
              color:#5A3A42">
        Atelier is a place for creative arts education. Get a head start in learning at your own speed with a group of enthusiastic creatives and develop a portfolio!
    </p>
    <div class="grid-stats" 
         style="margin-top:40px;
                max-width:800px;
                margin-left:auto;
                margin-right:auto">
        <div class="stat-card">
            <div class="stat-number">6</div>
            <div class="stat-label">
                Expert-led courses
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-number">6</div>
            <div class="stat-label">
                Creative disciplines
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-number">24/7</div>
            <div class="stat-label">
                Learn anytime
            </div>
        </div>
    </div>
</div>

</asp:Content>   
            
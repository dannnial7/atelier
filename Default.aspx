<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Atelier._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        #hero {
            position: relative;
            padding: 80px 20px 60px;
            text-align: center;
            overflow: hidden;
            background-color: #F8FAFC;
            border-bottom: 1px solid #E2E8F0;
        }
        #hero::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: url('<%= ResolveUrl("~/Images/hero-bg.jpg") %>');
            background-size: cover;
            background-position: center 35%;
            background-repeat: no-repeat;
            opacity: 0.20;
            z-index: 1;
            pointer-events: none;
        }
        #hero > * {
            position: relative;
            z-index: 2;
        }
    </style>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div id="hero">
        <h1 style="font-size:42px;font-weight:700;color:#0f172a;margin-bottom:12px;">One Platform. Endless Creativity.</h1>
        <p style="font-size:18px;color:#475569;max-width:700px;margin:0 auto 24px;">Master Visual Arts, Digital Art, Photography, Film & Video and Music at your own pace.</p>
        <div style="display:flex;gap:12px; justify-content:center; margin-top:20px">
            <a href="~/Courses.aspx" runat="server" class="btn btn-secondary" style="color:#6B1A2A !important; border:1.5px solid #6B1A2A !important; background:#ffffff !important; font-weight:600; padding:10px 24px;"> Browse Courses </a>
            <a href="~/Register.aspx" runat="server" class="btn btn-secondary" style="color:#ffffff !important; background:#6B1A2A !important; font-weight:600; padding:10px 24px;"> Join to be part of the community! </a>
        </div>
    </div>
    <div class="container">
        <div class="grid-stats" style="margin:40px 0;display:grid;grid-template-columns:repeat(3, 1fr);gap:32px;align-items:center;"> 
            <%-- Left: Enlarged SDG 4 Logo --%>
            <div style="display:flex;justify-content:center;align-items:center;">
                <img src="~/Images/SDG4.png" runat="server" alt="SDG 4 Quality Education" style="max-width:140px;width:100%;height:auto;border-radius:16px;box-shadow:0 10px 28px rgba(0,0,0,0.14);" />
            </div>

            <%-- Middle Card: 6 Creative Disciplines --%>
            <div class="stat-card middle-stat-card"> 
                <div class="stat-number">6</div>
                <div class="stat-label">Creative Disciplines</div>
            </div>

            <%-- Right: Enlarged SDG 8 Logo --%>
            <div style="display:flex;justify-content:center;align-items:center;">
                <img src="~/Images/SDG8.png" runat="server" alt="SDG 8 Decent Work and Economic Growth" style="max-width:140px;width:100%;height:auto;border-radius:16px;box-shadow:0 10px 28px rgba(0,0,0,0.14);" />
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

    <div class="about-section" style="padding:60px 40px;text-align:center;margin-top:40px;">
    <h2>Why Choose Atelier?</h2>
    <p class="about-description" style="max-width:600px;margin:16px auto;">
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
            
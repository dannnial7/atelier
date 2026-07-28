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
        <div class="grid-stats" style="margin:40px 0;display:grid;grid-template-columns:repeat(3, 1fr);gap:32px;align-items:center;"> 
            <%-- Left: Enlarged SDG 4 Logo --%>
            <div style="display:flex;justify-content:center;align-items:center;">
                <img src="~/Images/SDG4.png" runat="server" alt="SDG 4 Quality Education" style="max-width:140px;width:100%;height:auto;border-radius:16px;box-shadow:0 10px 28px rgba(0,0,0,0.14);" />
            </div>

            <%-- Middle Card: 6 Creative Disciplines --%>
            <div class="stat-card" style="display:flex;flex-direction:column;align-items:center;justify-content:center;padding:28px 20px;background:#ffffff !important;border:1px solid #e2e8f0;border-radius:16px;box-shadow:0 8px 24px rgba(0,0,0,0.08);"> 
                <div class="stat-number" style="font-size:48px;font-weight:800;color:#6B1A2A;line-height:1;margin-bottom:8px;">6</div>
                <div class="stat-label" style="font-weight:700;color:#0f172a;font-size:16px;">Creative Disciplines</div>
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
            
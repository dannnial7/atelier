<%@ Page Title="Announcements" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Announcements.aspx.cs" Inherits="Atelier.Announcements" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .announcement-card {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.04);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .announcement-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        }
        .announcement-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid #F1F5F9;
        }
        .announcement-title {
            font-size: 20px;
            font-weight: 700;
            color: #0F172A;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .announcement-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
            color: #64748B;
        }
        .announcement-body {
            font-size: 15px;
            color: #334155;
            line-height: 1.6;
            white-space: pre-wrap;
        }
        .announcement-badge {
            background: #FDF2F4;
            color: #6B1A2A;
            font-weight: 600;
            font-size: 12px;
            padding: 4px 10px;
            border-radius: 20px;
            border: 1px solid #F87171;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        /* Dark Mode Compatibility */
        .dark-mode .announcement-card {
            background-color: #241223 !important;
            border-color: #3D1E3A !important;
            box-shadow: 0 4px 16px rgba(0,0,0,0.2);
        }
        .dark-mode .announcement-header {
            border-bottom-color: #381C38 !important;
        }
        .dark-mode .announcement-title,
        .dark-mode h1 {
            color: #F8FAFC !important;
        }
        .dark-mode .announcement-meta {
            color: #CBD5E1 !important;
        }
        .dark-mode .announcement-body {
            color: #E2E8F0 !important;
        }
        .dark-mode .announcement-badge {
            background-color: #3B1B36 !important;
            color: #E2B6C0 !important;
            border-color: #8B2035 !important;
        }
        .dark-mode .announcement-header-icon {
            background-color: #3B1B36 !important;
            color: #E2B6C0 !important;
            box-shadow: 0 6px 16px rgba(0,0,0,0.4) !important;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div id="divAnnouncementsBg" class="announcements-bg-backdrop" style="position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:0;background-image:url('Images/announcements-bg.jpg');background-size:cover;background-position:center;background-repeat:no-repeat;opacity:0.30;pointer-events:none;"></div>

    <div class="container" style="position:relative;z-index:1;margin-top:40px;margin-bottom:60px;max-width:900px;">
        
        <!-- Header Banner -->
        <div style="text-align:center;margin-bottom:36px;">
            <div class="announcement-header-icon" style="display:inline-flex;align-items:center;justify-content:center;width:56px;height:56px;border-radius:50%;background:#FDF2F4;color:#6B1A2A;margin-bottom:12px;box-shadow:0 6px 16px rgba(107,26,42,0.15);">
                <svg width="28" height="28" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path d="M11 5L6 9H2v6h4l5 4V5z"></path>
                    <path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"></path>
                </svg>
            </div>
            <h1 style="font-size:32px;font-weight:800;margin:0 0 8px 0;">Platform Announcements</h1>
            <p style="font-size:16px;color:#64748B;margin:0;max-width:600px;margin:0 auto;">
                Stay updated with the latest news, platform releases, and official updates from the Atelier team.
            </p>
        </div>

        <!-- Announcements List -->
        <asp:Repeater ID="rptAnnouncements" runat="server">
            <ItemTemplate>
                <div class="announcement-card">
                    <div class="announcement-header">
                        <h3 class="announcement-title">
                            <svg width="18" height="18" fill="none" stroke="#6B1A2A" stroke-width="2.2" viewBox="0 0 24 24" style="flex-shrink:0;">
                                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                            </svg>
                            <%# Server.HtmlEncode(Eval("Title").ToString()) %>
                        </h3>
                        <span class="announcement-badge">
                            <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <circle cx="12" cy="12" r="10"></circle>
                                <polyline points="12 6 12 12 16 14"></polyline>
                            </svg>
                            <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy, HH:mm") %>
                        </span>
                    </div>
                    
                    <div class="announcement-body"><%# Server.HtmlEncode(Eval("Body").ToString().Trim()) %></div>

                    <div class="announcement-meta" style="margin-top:16px;padding-top:12px;border-top:1px dashed #E2E8F0;">
                        <span>Posted by <strong><%# Server.HtmlEncode(Eval("PostedBy").ToString()) %></strong></span>
                        <span>&middot;</span>
                        <span>Official Update</span>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- Empty State Panel -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" style="text-align:center;padding:48px 24px;background:#FFFFFF;border-radius:16px;border:1px solid #E2E8F0;box-shadow:0 4px 16px rgba(0,0,0,0.04);">
            <svg width="48" height="48" fill="none" stroke="#94A3B8" stroke-width="1.5" viewBox="0 0 24 24" style="margin-bottom:12px;">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            <h3 style="font-size:18px;font-weight:700;color:#334155;margin:0 0 6px 0;">No Announcements Yet</h3>
            <p style="font-size:14px;color:#64748B;margin:0;">Check back later for platform news and updates!</p>
        </asp:Panel>

    </div>
</asp:Content>

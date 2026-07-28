<%@ Page Title="Leaderboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs" Inherits="Atelier.Leaderboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .rank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            border-radius: 50%;
            font-weight: 700;
            font-size: 15px;
            background: #F1F5F9;
            color: #475569;
        }
        .rank-1 { background: #FDE047; color: #854D0E; box-shadow: 0 4px 12px rgba(250,204,21,0.4); }
        .rank-2 { background: #E2E8F0; color: #334155; box-shadow: 0 4px 12px rgba(148,163,184,0.3); }
        .rank-3 { background: #FDBA74; color: #9A3412; box-shadow: 0 4px 12px rgba(249,115,22,0.3); }

        .leaderboard-row {
            display: grid;
            grid-template-columns: 70px 1fr 140px 120px;
            align-items: center;
            gap: 16px;
            padding: 16px 24px;
            border-bottom: 1px solid #E2E8F0;
            transition: background-color 0.2s ease;
        }
        .leaderboard-row:hover {
            background-color: #F8FAFC;
        }
        .leaderboard-row.is-you {
            background: #EFF6FF;
            border-left: 4px solid #6B1A2A;
            font-weight: 600;
        }
        .leaderboard-head {
            display: grid;
            grid-template-columns: 70px 1fr 140px 120px;
            gap: 16px;
            padding: 14px 24px;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748B;
            background: #F8FAFC;
            border-bottom: 2px solid #E2E8F0;
            border-radius: 12px 12px 0 0;
        }
        @media (max-width: 600px) {
            .leaderboard-row, .leaderboard-head {
                grid-template-columns: 50px 1fr 90px;
            }
            .hide-mobile { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <div style="text-align:center;margin-bottom:32px;">
            <h1 style="font-size:36px;color:#0f172a;font-weight:700;">
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-6px;margin-right:8px;"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"></path><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"></path><path d="M4 22h16"></path><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"></path><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"></path><path d="M18 2H6v7a6 6 0 0 0 12 0V2z"></path></svg>Platform Leaderboard
            </h1>
            <p style="color:#64748b;font-size:16px;max-width:600px;margin:8px auto 0;">
                Celebrating top creative learners ranked by total Experience Points (XP) and badges earned across all courses.
            </p>
        </div>

        <%-- Learner Standing Card --%>
        <asp:Panel ID="pnlYourRank" runat="server" Visible="false"
                   CssClass="card" style="margin:24px 0;padding:24px;background:#ffffff;border:1px solid #e2e8f0;border-radius:16px;box-shadow:0 8px 24px rgba(0,0,0,0.06);">
            <h3 style="margin-top:0;margin-bottom:16px;font-size:18px;color:#0f172a;">Your Current Rank & Standing</h3>
            <div class="grid-stats">
                <div class="stat-card" style="background:#F8FAFC;padding:16px;border-radius:12px;text-align:center;">
                    <asp:Label ID="lblYourRank" runat="server" CssClass="stat-number" style="font-size:32px;font-weight:700;color:#6B1A2A;" />
                    <div class="stat-label" style="font-size:13px;color:#64748b;margin-top:4px;">Your Rank</div>
                </div>
                <div class="stat-card" style="background:#F8FAFC;padding:16px;border-radius:12px;text-align:center;">
                    <asp:Label ID="lblYourXP" runat="server" CssClass="stat-number" style="font-size:32px;font-weight:700;color:#059669;" />
                    <div class="stat-label" style="font-size:13px;color:#64748b;margin-top:4px;">Your Total XP</div>
                </div>
                <div class="stat-card" style="background:#F8FAFC;padding:16px;border-radius:12px;text-align:center;">
                    <asp:Label ID="lblTotalLearners" runat="server" CssClass="stat-number" style="font-size:32px;font-weight:700;color:#0284c7;" />
                    <div class="stat-label" style="font-size:13px;color:#64748b;margin-top:4px;">Total Active Learners</div>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="alert alert-info" style="padding:20px;border-radius:12px;">
                No experience points have been earned yet. Complete a module or pass a quiz to appear on the leaderboard!
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlBoard" runat="server" CssClass="card" style="padding:0;background:#ffffff;border:1px solid #e2e8f0;border-radius:16px;box-shadow:0 12px 36px rgba(0,0,0,0.08);overflow:hidden;margin-bottom:40px;">

            <div class="leaderboard-head">
                <div>Rank</div>
                <div>Learner Name</div>
                <div class="hide-mobile">Badges Earned</div>
                <div>Total XP</div>
            </div>

            <asp:Repeater ID="rptLeaderboard" runat="server">
                <ItemTemplate>
                    <div class='<%# Convert.ToInt32(Eval("UserID")) == CurrentUserId
                                    ? "leaderboard-row is-you"
                                    : "leaderboard-row" %>'>
                        <div>
                            <span class='<%# GetRankClass(Container.ItemIndex + 1) %>'>
                                <%# GetRankIcon(Container.ItemIndex + 1) %>
                            </span>
                        </div>
                        <div style="font-size:16px;color:#0f172a;">
                            <strong><%# Eval("FullName") %></strong>
                            <%# Convert.ToInt32(Eval("UserID")) == CurrentUserId
                                ? " <span class='badge badge-primary' style='font-size:11px;margin-left:6px;'>You</span>"
                                : "" %>
                        </div>
                        <div class="hide-mobile course-meta" style="font-size:14px;color:#475569;">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:4px;"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg><%# Eval("BadgeCount") %> badges
                        </div>
                        <div style="font-size:16px;font-weight:700;color:#6B1A2A;">
                            <%# Eval("TotalXP") %> XP
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </asp:Panel>

    </div>

</asp:Content>
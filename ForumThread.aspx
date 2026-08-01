<%@ Page Title="Thread" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ForumThread.aspx.cs" Inherits="Atelier.ForumThread" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .thread-detail-card {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: var(--radius-lg);
            padding: 28px 32px;
            margin-bottom: 24px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
        }

        .dark-mode .thread-detail-card {
            background: #1E1218;
            border-color: rgba(255, 255, 255, 0.12);
        }

        .reply-card {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: var(--radius-md);
            padding: 20px 24px;
            margin-bottom: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
            transition: border-color 0.2s ease;
        }

        .reply-card:hover {
            border-color: rgba(107, 26, 42, 0.25);
        }

        .dark-mode .reply-card {
            background: #1A0D14;
            border-color: rgba(255, 255, 255, 0.1);
        }

        .reply-body {
            font-size: 15px;
            line-height: 1.6;
            color: var(--text-color);
            white-space: pre-wrap;
            margin-top: 10px;
        }

        .badge-pinned {
            background: #6B1A2A;
            color: #FFFFFF;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 6px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-right: 6px;
        }

        .badge-locked {
            background: #B45309;
            color: #FFFFFF;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 6px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-right: 6px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container" style="padding-top: 32px; padding-bottom: 48px;">

        <div style="margin-bottom:24px; text-align:left;">
            <a href="Forum.aspx" style="display:inline-flex;align-items:center;gap:6px;color:#6B1A2A;font-weight:600;text-decoration:none;font-size:14px;">
                &larr; Back to All Discussions
            </a>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-success" Visible="false" style="display:block;margin-bottom:20px;text-align:left;" />

        <asp:Panel ID="pnlThread" runat="server">
            <div class="thread-detail-card" style="text-align:left;">
                <div style="margin-bottom:16px;text-align:left;">
                    <h2 style="font-size:28px;font-weight:700;margin-bottom:12px;line-height:1.2;color:var(--text-heading);text-align:left;">
                        <asp:Literal ID="litPinned" runat="server" />
                        <asp:Literal ID="litLocked" runat="server" />
                        <asp:Literal ID="litTitle" runat="server" />
                    </h2>
                    <div style="font-size:13.5px;color:var(--muted-colour);display:flex;align-items:center;gap:10px;flex-wrap:wrap;justify-content:flex-start;">
                        <span>Posted by <strong style="color:#6B1A2A;"><asp:Literal ID="litAuthor" runat="server" /></strong></span>
                        <span>&bull;</span>
                        <span>in <strong><asp:Literal ID="litCourse" runat="server" /></strong></span>
                        <span>&bull;</span>
                        <span><asp:Literal ID="litDate" runat="server" /></span>
                        <span>&bull;</span>
                        <span style="display:inline-flex;align-items:center;gap:4px;">
                            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                            <asp:Literal ID="litViews" runat="server" /> views
                        </span>
                    </div>
                </div>

                <div class="reply-body" style="font-size:16px;padding:12px 0;border-top:1px solid #E8E0E2;border-bottom:1px solid #E8E0E2;margin:12px 0 0 0;text-align:left;"><asp:Literal ID="litBody" runat="server" /></div>

                <div style="display:flex;gap:10px;justify-content:flex-start;margin-top:16px;">
                    <asp:Panel ID="pnlOwnerActions" runat="server" Visible="false" style="display:inline-flex;gap:10px;">
                        <asp:Button ID="btnShowEdit" runat="server" Text="Edit Thread" CssClass="btn btn-secondary btn-sm"
                            CausesValidation="false" OnClick="btnShowEdit_Click" />
                        <asp:Button ID="btnDeleteThread" runat="server" Text="Delete Thread" CssClass="btn btn-danger btn-sm" style="background:#991B1B;border-color:#991B1B;"
                            CausesValidation="false" OnClick="btnDeleteThread_Click"
                            OnClientClick="return confirm('Delete this thread and all its replies?');" />
                    </asp:Panel>
                    <asp:Button ID="btnReportThread" runat="server" Text="🚩 Report Thread" CssClass="btn btn-secondary btn-sm"
                        CausesValidation="false" OnClick="btnReportThread_Click" style="font-weight:600;" />
                </div>
            </div>

            <!-- Report Thread Modal -->
            <asp:Panel ID="pnlReportModal" runat="server" Visible="false" style="position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(0,0,0,0.6);z-index:99999;display:flex;align-items:center;justify-content:center;">
                <div class="card" style="width:100%;max-width:480px;background:#FFFFFF;border-radius:16px;padding:24px;box-shadow:0 20px 40px rgba(0,0,0,0.25);">
                    <h3 style="font-size:20px;font-weight:700;margin-bottom:12px;color:#991B1B;">Report Thread to Admin</h3>
                    <p style="font-size:13.5px;color:var(--muted-colour);margin-bottom:16px;">Please specify why you are reporting this thread. Administrators will review your report.</p>
                    <div class="form-group" style="margin-bottom:16px;">
                        <label style="font-size:13px;font-weight:600;display:block;margin-bottom:6px;">Reason for Reporting</label>
                        <asp:DropDownList ID="ddlReportReason" runat="server" CssClass="form-control" style="width:100%;padding:10px 12px;border-radius:8px;">
                            <asp:ListItem Value="Inappropriate Content">Inappropriate Content</asp:ListItem>
                            <asp:ListItem Value="Harassment or Hate Speech">Harassment or Hate Speech</asp:ListItem>
                            <asp:ListItem Value="Spam or Misleading">Spam or Misleading</asp:ListItem>
                            <asp:ListItem Value="Copyright Violation">Copyright Violation</asp:ListItem>
                            <asp:ListItem Value="Other">Other</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
                        <asp:Button ID="btnCancelReport" runat="server" Text="Cancel" CssClass="btn btn-secondary" CausesValidation="false" OnClick="btnCancelReport_Click" />
                        <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report" CssClass="btn btn-danger" OnClick="btnSubmitReport_Click" style="background:#991B1B;border-color:#991B1B;" />
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlEdit" runat="server" Visible="false" CssClass="thread-detail-card" style="text-align:left;">
                <h3 style="font-size:20px;font-weight:700;margin-bottom:16px;text-align:left;">Edit Thread</h3>
                <div class="form-row" style="margin-bottom:16px;text-align:left;">
                    <label style="display:block;margin-bottom:6px;font-weight:600;text-align:left;">Title</label>
                    <asp:TextBox ID="txtEditTitle" runat="server" MaxLength="200" CssClass="form-control" style="width:100%;padding:10px 14px;border-radius:10px;border:1px solid #E8E0E2;" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditTitle"
                        ErrorMessage="Title is required." CssClass="field-error"
                        Display="Dynamic" ValidationGroup="EditThread" />
                </div>
                <div class="form-row" style="margin-bottom:20px;text-align:left;">
                    <label style="display:block;margin-bottom:6px;font-weight:600;text-align:left;">Message</label>
                    <asp:TextBox ID="txtEditBody" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control" style="width:100%;padding:12px 14px;border-radius:10px;border:1px solid #E8E0E2;resize:vertical;" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditBody"
                        ErrorMessage="Message is required." CssClass="field-error"
                        Display="Dynamic" ValidationGroup="EditThread" />
                </div>
                <div style="display:flex;gap:10px;justify-content:flex-start;">
                    <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes"
                        CssClass="btn btn-primary" OnClick="btnSaveEdit_Click" ValidationGroup="EditThread" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CausesValidation="false"
                        CssClass="btn btn-secondary" OnClick="btnCancelEdit_Click" />
                </div>
            </asp:Panel>

            <h3 style="display:flex;align-items:center;gap:8px;font-size:20px;font-weight:700;margin:32px 0 16px 0;color:var(--text-heading);text-align:left;">
                <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="color:#6B1A2A;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                Discussion Replies
            </h3>

            <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
                <ItemTemplate>
                    <div class="reply-card" style="text-align:left;padding:20px 24px;margin-bottom:16px;">
                        <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:8px;">
                            <div style="font-size:14px;color:var(--muted-colour);text-align:left;">
                                <a href='<%# "UserProfile.aspx?id=" + Eval("UserID") %>' 
                                   style="color:#6B1A2A;font-weight:700;text-decoration:none;">
                                    <%# Server.HtmlEncode(Eval("FullName").ToString()) %>
                                </a>
                                &bull; <%# Convert.ToDateTime(Eval("PostedAt")).ToString("dd MMM yyyy, HH:mm") %>
                            </div>
                            <asp:Button runat="server" Text="Delete" CommandName="DeleteReply"
                                CommandArgument='<%# Eval("ReplyID") %>'
                                CssClass="btn btn-danger btn-sm" style="background:#991B1B;border-color:#991B1B;font-size:11.5px;padding:3px 10px;"
                                Visible='<%# CanUserDelete(Eval("UserID")) %>'
                                OnClientClick="return confirm('Delete this reply?');"
                                CausesValidation="false" />
                        </div>
                        <div class="reply-body" style="font-size:15px;line-height:1.6;color:var(--text-color);margin-top:4px;text-align:left;"><%# Server.HtmlEncode(Eval("Body").ToString()) %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoReplies" runat="server" Visible="false" CssClass="thread-detail-card" style="text-align:left;padding:30px;">
                <p style="color:var(--muted-colour);margin:0;font-size:14px;text-align:left;">No replies yet. Be the first to share your thoughts!</p>
            </asp:Panel>

            <asp:Panel ID="pnlReplyForm" runat="server" CssClass="thread-detail-card" style="margin-top:28px;text-align:left;">
                <h3 style="font-size:18px;font-weight:700;margin-bottom:16px;color:var(--text-heading);text-align:left;">Post a Reply</h3>
                <div class="form-row" style="margin-bottom:16px;text-align:left;">
                    <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" placeholder="Share your response or feedback..." style="width:100%;padding:14px 16px;border-radius:12px;border:1px solid #E8E0E2;resize:vertical;" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReply"
                        ErrorMessage="Reply cannot be empty." CssClass="field-error"
                        Display="Dynamic" ValidationGroup="PostReply" />
                </div>
                <asp:Button ID="btnPostReply" runat="server" Text="Post Reply"
                    CssClass="btn btn-primary" OnClick="btnPostReply_Click" ValidationGroup="PostReply" style="padding:10px 24px;font-weight:600;" />
            </asp:Panel>

            <asp:Panel ID="pnlLocked" runat="server" Visible="false" CssClass="alert alert-warning" style="margin-top:20px;display:block;text-align:left;">
                <strong>Notice:</strong> This thread is locked by an admin. No new replies can be posted.
            </asp:Panel>

            <asp:Panel ID="pnlGuestNotice" runat="server" Visible="false" CssClass="thread-detail-card" style="margin-top:28px;text-align:center;padding:32px;">
                <h4 style="font-size:18px;font-weight:700;margin-bottom:8px;color:var(--text-heading);">Want to join the discussion?</h4>
                <p style="color:var(--muted-colour);font-size:14px;margin-bottom:20px;">Guests can read all community discussions. Sign in or create an account to post replies and engage with artists.</p>
                <div style="display:flex;gap:12px;justify-content:center;">
                    <a href="Login.aspx" class="btn btn-primary" style="padding:10px 24px;">Sign In</a>
                    <a href="Register.aspx" class="btn btn-secondary" style="padding:10px 24px;">Register</a>
                </div>
            </asp:Panel>
        </asp:Panel>

        <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="thread-detail-card" style="text-align:center;padding:40px;">
            <h4 style="font-size:18px;margin-bottom:10px;">Discussion Not Found</h4>
            <p style="margin-bottom:16px;color:var(--muted-colour);">The discussion thread you are looking for does not exist or has been removed.</p>
            <a href="Forum.aspx" class="btn btn-primary">Return to Community Forum</a>
        </asp:Panel>
    </div>
</asp:Content>
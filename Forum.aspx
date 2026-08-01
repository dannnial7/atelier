<%@ Page Title="Forum" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Forum.aspx.cs" Inherits="Atelier.Forum" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .forum-hero {
            background: linear-gradient(135deg, #4A1020 0%, #6B1A2A 50%, #8B2035 100%);
            border-radius: var(--radius-lg);
            padding: 36px 40px;
            color: #FFFFFF;
            margin-bottom: 28px;
            box-shadow: 0 12px 32px rgba(107, 26, 42, 0.2);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }

        .forum-hero h2 {
            color: #FFFFFF !important;
            font-size: 32px;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .forum-hero p {
            color: rgba(255, 255, 255, 0.85);
            font-size: 15px;
            margin: 0;
        }

        .forum-card-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: var(--radius-lg);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
        }

        .dark-mode .forum-card-panel {
            background: #1E1218;
            border-color: rgba(255, 255, 255, 0.12);
        }

        .forum-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 24px;
        }

        .forum-toolbar .filter-group {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .forum-toolbar label {
            font-weight: 600;
            font-size: 14px;
            color: var(--text-color);
        }

        .thread-item-card {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: var(--radius-md);
            padding: 20px 24px;
            margin-bottom: 16px;
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            max-width: 100%;
        }

        .thread-item-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(107, 26, 42, 0.1);
            border-color: rgba(107, 26, 42, 0.3);
        }

        .dark-mode .thread-item-card {
            background: #1A0D14;
            border-color: rgba(255, 255, 255, 0.1);
        }

        .thread-title-link {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 18px;
            font-weight: 600;
            color: var(--text-heading);
            text-decoration: none;
            display: inline-block;
            margin-bottom: 6px;
            line-height: 1.3;
            transition: color 0.2s ease;
        }

        .thread-title-link:hover {
            color: #6B1A2A;
            text-decoration: none;
        }

        .thread-user-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #6B1A2A;
            flex-shrink: 0;
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

        .badge-course {
            background: rgba(107, 26, 42, 0.08);
            color: #6B1A2A;
            font-size: 12px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 12px;
            display: inline-block;
        }

        .dark-mode .badge-course {
            background: rgba(191, 207, 232, 0.15);
            color: #BFCFE8;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container" style="padding-top:32px; padding-bottom:48px;">

        <%-- Hero Header Banner --%>
        <div class="forum-hero">
            <div>
                <h2>Community Forum</h2>
                <p>Connect, share creative artwork, ask questions, and engage with fellow Atelier artists.</p>
            </div>
            <asp:Button ID="btnShowNew" runat="server" Text="+ Start New Discussion"
                CssClass="btn btn-primary" style="background:#FFFFFF;color:#6B1A2A;border:none;font-weight:700;padding:12px 24px;border-radius:9999px;box-shadow:0 4px 14px rgba(0,0,0,0.15);"
                OnClientClick="document.getElementById('newThreadPanel').style.display='block'; return false;" />
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-success" Visible="false" style="display:block;margin-bottom:20px;text-align:left;" />

        <%-- New Thread Form Panel --%>
        <div id="newThreadPanel" class="forum-card-panel" style="display:none;text-align:left;">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;padding-bottom:12px;border-bottom:1px solid #E8E0E2;">
                <h3 style="margin:0;font-size:20px;font-weight:700;color:var(--text-heading);">Start a New Discussion</h3>
                <button type="button" onclick="document.getElementById('newThreadPanel').style.display='none';" style="background:none;border:none;font-size:24px;cursor:pointer;color:var(--muted-colour);">&times;</button>
            </div>
            
            <div class="form-row" style="margin-bottom:16px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">Select Associated Course</label>
                <asp:DropDownList ID="ddlNewCourse" runat="server" CssClass="form-control" style="width:100%;padding:10px 14px;border-radius:10px;border:1px solid #E8E0E2;" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlNewCourse"
                    InitialValue="" ErrorMessage="Please select a course." CssClass="field-error"
                    Display="Dynamic" ValidationGroup="NewThread" />
            </div>
            
            <div class="form-row" style="margin-bottom:16px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">Discussion Title</label>
                <asp:TextBox ID="txtTitle" runat="server" MaxLength="200" CssClass="form-control" placeholder="What would you like to discuss or share?" style="width:100%;padding:10px 14px;border-radius:10px;border:1px solid #E8E0E2;" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                    ErrorMessage="Title is required." CssClass="field-error"
                    Display="Dynamic" ValidationGroup="NewThread" />
            </div>
            
            <div class="form-row" style="margin-bottom:20px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">Message & Details</label>
                <asp:TextBox ID="txtBody" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control" placeholder="Write your full discussion post details here..." style="width:100%;padding:12px 14px;border-radius:10px;border:1px solid #E8E0E2;resize:vertical;" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtBody"
                    ErrorMessage="Message body is required." CssClass="field-error"
                    Display="Dynamic" ValidationGroup="NewThread" />
            </div>
            
            <div style="display:flex;gap:12px;">
                <asp:Button ID="btnCreate" runat="server" Text="Post Discussion"
                    CssClass="btn btn-primary" OnClick="btnCreate_Click" ValidationGroup="NewThread" style="padding:10px 24px;" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false"
                    CssClass="btn btn-secondary" style="padding:10px 20px;"
                    OnClientClick="document.getElementById('newThreadPanel').style.display='none'; return false;" />
            </div>
        </div>

        <%-- Filter Toolbar --%>
        <div class="forum-card-panel" style="padding:16px 24px;margin-bottom:20px;text-align:left;">
            <div class="forum-toolbar" style="margin-bottom:0;">
                <div class="filter-group">
                    <label style="margin:0;">Filter Discussions by Course:</label>
                    <asp:DropDownList ID="ddlFilterCourse" runat="server" AutoPostBack="true"
                        CssClass="form-control" style="padding:8px 14px;border-radius:8px;border:1px solid #E8E0E2;font-size:14px;"
                        OnSelectedIndexChanged="ddlFilterCourse_SelectedIndexChanged" />
                </div>
                <div style="font-size:13.5px;color:var(--muted-colour);font-weight:500;">
                    Showing live community threads
                </div>
            </div>
        </div>

        <%-- Threads Repeater List --%>
        <asp:Repeater ID="rptThreads" runat="server" OnItemCommand="rptThreads_ItemCommand">
            <ItemTemplate>
                <div class="thread-item-card" style="text-align:left;">
                    <div style="display:flex;gap:16px;align-items:flex-start;text-align:left;">
                        <!-- User Avatar -->
                        <img src='<%# Eval("ProfilePic") != null && !string.IsNullOrEmpty(Eval("ProfilePic").ToString()) ? Eval("ProfilePic") : "Images/default-avatar.png" %>' 
                             class="thread-user-avatar" 
                             alt="Avatar"
                             onerror="this.onerror=null;this.src='Images/default-avatar.png';" />

                        <div style="flex:1;text-align:left;">
                            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:4px;">
                                <%# Convert.ToBoolean(Eval("Pinned")) ? "<span class=\"badge-pinned\">Pinned</span>" : "" %>
                                <%# Convert.ToBoolean(Eval("Locked")) ? "<span class=\"badge-locked\">Locked</span>" : "" %>
                                <span class="badge-course"><%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %></span>
                            </div>

                            <a class="thread-title-link" href='ForumThread.aspx?id=<%# Eval("ForumID") %>'>
                                <%# Server.HtmlEncode(Eval("Title").ToString()) %>
                            </a>

                            <div style="font-size:13px;color:var(--muted-colour);display:flex;align-items:center;gap:12px;flex-wrap:wrap;margin-top:4px;text-align:left;">
                                <span>Started by 
                                    <a href='<%# "UserProfile.aspx?id=" + Eval("UserID") %>' 
                                       onclick='<%# string.Format("openUserPreview(\"{0}\", \"{1}\", \"{2}\", \"{3}\", \"{4}\"); return false;", Server.HtmlEncode(Eval("FullName").ToString()), Server.HtmlEncode(Eval("Bio").ToString().Replace("\r", "").Replace("\n", " ")), Eval("TotalXP"), Eval("BadgeCount"), Eval("ProfilePic")) %>' 
                                       style="color:#6B1A2A;font-weight:700;text-decoration:none;">
                                        <%# Server.HtmlEncode(Eval("FullName").ToString()) %>
                                    </a>
                                </span>
                                <span>&bull;</span>
                                <span><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy, HH:mm") %></span>
                            </div>
                        </div>

                        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:10px;flex-shrink:0;">
                            <div style="display:flex;align-items:center;gap:14px;font-size:13px;color:var(--muted-colour);">
                                <span style="display:inline-flex;align-items:center;gap:4px;">
                                    <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                                    <strong><%# Eval("ReplyCount") %></strong> replies
                                </span>
                                <span style="display:inline-flex;align-items:center;gap:4px;">
                                    <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                    <strong><%# Eval("ViewCount") %></strong> views
                                </span>
                            </div>

                            <asp:Button runat="server" Text="Delete" CommandName="DeleteThread"
                                CommandArgument='<%# Eval("ForumID") %>'
                                CssClass="btn btn-danger btn-sm" style="background:#991B1B;border-color:#991B1B;font-size:12px;padding:4px 12px;"
                                Visible='<%# CanUserDelete(Eval("UserID")) %>'
                                OnClientClick="return confirm('Are you sure you want to delete this thread and all its replies?');"
                                CausesValidation="false" />
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="forum-card-panel" style="text-align:center;padding:40px;">
            <svg width="48" height="48" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" style="color:var(--muted-colour);margin-bottom:12px;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
            <h4 style="font-size:18px;font-weight:600;margin-bottom:6px;">No discussions yet</h4>
            <p style="color:var(--muted-colour);font-size:14px;margin:0;">Be the first to start a conversation in this topic!</p>
        </asp:Panel>
    </div>
</asp:Content>
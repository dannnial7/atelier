<%@ Page Title="Portfolio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Portfolio.aspx.cs" Inherits="Atelier.Portfolio" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .portfolio-hero {
            background: linear-gradient(135deg, #6B1A2A 0%, #4A1020 100%);
            color: #FFFFFF;
            padding: 40px 48px;
            border-radius: var(--radius-lg);
            margin-bottom: 32px;
            box-shadow: 0 8px 24px rgba(107, 26, 42, 0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .portfolio-hero h2 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #FFFFFF;
        }

        .portfolio-hero p {
            font-size: 15px;
            color: rgba(255, 255, 255, 0.85);
            margin: 0;
            max-width: 600px;
        }

        .portfolio-card-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: var(--radius-lg);
            padding: 32px;
            margin-bottom: 32px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
            text-align: left;
        }

        .dark-mode .portfolio-card-panel {
            background: #1E1218;
            border-color: rgba(255, 255, 255, 0.12);
        }

        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .portfolio-item-card {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: var(--radius-md);
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03);
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            display: flex;
            flex-direction: column;
            text-align: left;
        }

        .portfolio-item-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(107, 26, 42, 0.12);
            border-color: rgba(107, 26, 42, 0.3);
        }

        .dark-mode .portfolio-item-card {
            background: #1A0D14;
            border-color: rgba(255, 255, 255, 0.1);
        }

        .portfolio-thumb {
            width: 100%;
            height: 190px;
            object-fit: cover;
            background: #F0F4F9;
            border-bottom: 1px solid #E8E0E2;
        }

        .portfolio-filebox {
            width: 100%;
            height: 190px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: #F0F4F9;
            border-bottom: 1px solid #E8E0E2;
            color: #6B1A2A;
            gap: 8px;
            font-weight: 600;
            font-size: 14px;
        }

        .dark-mode .portfolio-thumb,
        .dark-mode .portfolio-filebox {
            background: #251820;
            border-bottom-color: rgba(255, 255, 255, 0.1);
            color: #BFCFE8;
        }

        .portfolio-card-body {
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .portfolio-title {
            font-size: 17px;
            font-weight: 700;
            color: var(--text-heading);
            margin-bottom: 8px;
            line-height: 1.3;
        }

        .portfolio-meta {
            font-size: 13px;
            color: var(--muted-colour);
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }

        .badge-featured {
            background: #6B1A2A;
            color: #FFFFFF;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 6px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .badge-course-tag {
            background: #F0F4F9;
            color: #6B1A2A;
            font-size: 11.5px;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 6px;
            border: 0.5px solid #E8E0E2;
        }

        .dark-mode .badge-course-tag {
            background: rgba(255, 255, 255, 0.08);
            color: #BFCFE8;
            border-color: rgba(255, 255, 255, 0.12);
        }

        .section-header-title {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-heading);
            margin: 36px 0 20px 0;
            display: flex;
            align-items: center;
            gap: 10px;
            text-align: left;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container" style="padding-top: 32px; padding-bottom: 48px;">

        <%-- Hero Header Banner --%>
        <div class="portfolio-hero">
            <div>
                <h2>Student Artwork Showcase</h2>
                <p>Upload project submissions, build your creative portfolio, and discover artwork from fellow Atelier artists.</p>
            </div>
            <button type="button" class="btn btn-primary" style="background:#FFFFFF;color:#6B1A2A;border:none;font-weight:700;padding:12px 24px;border-radius:9999px;box-shadow:0 4px 14px rgba(0,0,0,0.15);"
                onclick="document.getElementById('uploadPanel').style.display='block'; window.scrollTo({top: 200, behavior: 'smooth'});">
                + Upload New Work
            </button>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-success" Visible="false" style="display:block;margin-bottom:20px;text-align:left;" />

        <%-- Upload Form Panel --%>
        <div id="uploadPanel" class="portfolio-card-panel" style="display:none;">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;padding-bottom:12px;border-bottom:1px solid #E8E0E2;">
                <h3 style="margin:0;font-size:20px;font-weight:700;color:var(--text-heading);">Upload New Artwork or Project</h3>
                <button type="button" onclick="document.getElementById('uploadPanel').style.display='none';" style="background:none;border:none;font-size:24px;cursor:pointer;color:var(--muted-colour);">&times;</button>
            </div>

            <div class="form-row" style="margin-bottom:16px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">Associated Course</label>
                <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" style="width:100%;" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlCourse"
                    InitialValue="" ErrorMessage="Please select a course." CssClass="field-error"
                    Display="Dynamic" ValidationGroup="Upload" />
            </div>

            <div class="form-row" style="margin-bottom:16px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">Project Title</label>
                <asp:TextBox ID="txtTitle" runat="server" MaxLength="200" CssClass="form-control" placeholder="Give your artwork a title..." style="width:100%;padding:10px 14px;border-radius:10px;border:1px solid #E8E0E2;" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                    ErrorMessage="Title is required." CssClass="field-error"
                    Display="Dynamic" ValidationGroup="Upload" />
            </div>

            <div class="form-row" style="margin-bottom:16px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">Description & Notes</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" placeholder="Tell us about your tools, technique, or inspiration..." style="width:100%;padding:12px 14px;border-radius:10px;border:1px solid #E8E0E2;resize:vertical;" />
            </div>

            <div class="form-row" style="margin-bottom:24px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:14px;">File Attachment <span style="font-weight:400;color:var(--muted-colour);">(PDF, JPEG, PNG, MP4, ZIP, DOCX — max 10 MB)</span></label>
                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="fileUpload"
                    ErrorMessage="Please choose a file to upload." CssClass="field-error"
                    Display="Dynamic" ValidationGroup="Upload" />
            </div>

            <div style="display:flex;gap:12px;">
                <asp:Button ID="btnUpload" runat="server" Text="Upload Submission" CssClass="btn btn-primary"
                    OnClick="btnUpload_Click" ValidationGroup="Upload" style="padding:10px 24px;font-weight:600;" />
                <button type="button" class="btn btn-secondary" style="padding:10px 20px;" onclick="document.getElementById('uploadPanel').style.display='none';">Cancel</button>
            </div>
        </div>

        <%-- My Submissions Section --%>
        <h3 class="section-header-title">
            <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="color:#6B1A2A;"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
            My Portfolio Work
        </h3>

        <asp:Repeater ID="rptMine" runat="server" OnItemCommand="rptMine_ItemCommand">
            <HeaderTemplate><div class="gallery-grid"></HeaderTemplate>
            <ItemTemplate>
                <div class="portfolio-item-card">
                    <%# RenderThumb(Eval("FileURL")) %>
                    <div class="portfolio-card-body">
                        <div>
                            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:6px;">
                                <%# (bool)Eval("IsFeatured") ? "<span class='badge-featured'>Featured</span>" : "" %>
                                <span class="badge-course-tag"><%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %></span>
                            </div>
                            <h4 class="portfolio-title"><%# Server.HtmlEncode(Eval("Title").ToString()) %></h4>
                            <div class="portfolio-meta">
                                <span>&bull; <%# Eval("LikeCountT") %> likes</span>
                                <span>&bull; <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %></span>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;margin-top:12px;padding-top:12px;border-top:1px solid #E8E0E2;">
                            <asp:Button runat="server" Text="Delete" CommandName="DeleteItem"
                                CommandArgument='<%# Eval("PortfolioID") %>' CssClass="btn btn-danger btn-sm" style="background:#991B1B;border-color:#991B1B;font-size:12px;padding:4px 12px;"
                                OnClientClick="return confirm('Delete this portfolio item?');" CausesValidation="false" />
                            <asp:Button runat="server"
                                Text='<%# (bool)Eval("IsFeatured") ? "Unfeature" : "Feature" %>'
                                CommandName="ToggleFeature" CommandArgument='<%# Eval("PortfolioID") %>'
                                CssClass="btn btn-secondary btn-sm" style="font-size:12px;padding:4px 12px;" CausesValidation="false" />
                            <a class="btn btn-secondary btn-sm" href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' target="_blank" style="margin-left:auto;font-size:12px;padding:4px 12px;">View</a>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNoMine" runat="server" Visible="false" CssClass="portfolio-card-panel" style="text-align:center;padding:40px;">
            <p style="color:var(--muted-colour);margin:0;font-size:14px;">You haven't uploaded any portfolio work yet. Click above to showcase your artwork!</p>
        </asp:Panel>

        <%-- Community Showcase Section --%>
        <h3 class="section-header-title">
            <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="color:#6B1A2A;"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
            Community Artwork Gallery
        </h3>

        <asp:Repeater ID="rptGallery" runat="server" OnItemCommand="rptGallery_ItemCommand">
            <HeaderTemplate><div class="gallery-grid"></HeaderTemplate>
            <ItemTemplate>
                <div class="portfolio-item-card">
                    <%# RenderThumb(Eval("FileURL")) %>
                    <div class="portfolio-card-body">
                        <div>
                            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:6px;">
                                <%# (bool)Eval("IsFeatured") ? "<span class='badge-featured'>Featured</span>" : "" %>
                                <span class="badge-course-tag"><%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %></span>
                            </div>
                            <h4 class="portfolio-title"><%# Server.HtmlEncode(Eval("Title").ToString()) %></h4>
                            <div class="portfolio-meta">
                                <span>By <strong><%# Server.HtmlEncode(Eval("FullName").ToString()) %></strong></span>
                                <span>&bull; <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %></span>
                            </div>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:12px;padding-top:12px;border-top:1px solid #E8E0E2;">
                            <asp:LinkButton runat="server" CommandName="LikeItem" CommandArgument='<%# Eval("PortfolioID") %>'
                                CssClass="btn btn-secondary btn-sm" style="font-weight:600;font-size:12.5px;padding:5px 14px;display:inline-flex;align-items:center;gap:6px;" CausesValidation="false">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" style="color:#E11D48;"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                Like (<%# Eval("LikeCountT") %>)
                            </asp:LinkButton>
                            <a class="btn btn-primary btn-sm" href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' target="_blank" style="font-weight:600;font-size:12.5px;padding:5px 16px;">View Work</a>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNoGallery" runat="server" Visible="false" CssClass="portfolio-card-panel" style="text-align:center;padding:40px;">
            <p style="color:var(--muted-colour);margin:0;font-size:14px;">No community artwork has been shared yet.</p>
        </asp:Panel>

    </div>
</asp:Content>
<%@ Page Title="Portfolio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Portfolio.aspx.cs" Inherits="Atelier.Portfolio" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .form-row { margin-bottom:12px; }
        .form-row label { display:block; margin-bottom:4px; font-weight:600; }
        .form-row input[type=text], .form-row textarea, .form-row select { width:100%; padding:8px; box-sizing:border-box; }
        .form-row textarea { min-height:80px; resize:vertical; }
        .gallery { display:grid; grid-template-columns:repeat(auto-fill, minmax(260px, 1fr)); gap:16px; }
        .p-item .thumb { width:100%; height:160px; object-fit:cover; border-radius:6px; background:#f0f0f0; }
        .p-item .filebox { width:100%; height:160px; display:flex; align-items:center; justify-content:center;
                            background:#f0f0f0; border-radius:6px; font-size:.9rem; color:#555; }
        .p-meta { font-size:.85rem; opacity:.75; margin-top:6px; }
        .p-actions { margin-top:8px; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Portfolio</h2>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

    <div class="card">
        <h3>Upload New Work</h3>
        <div class="form-row">
            <label>Course</label>
            <asp:DropDownList ID="ddlCourse" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlCourse"
                InitialValue="" ErrorMessage="Please select a course." CssClass="alert"
                Display="Dynamic" ValidationGroup="Upload" />
        </div>
        <div class="form-row">
            <label>Title</label>
            <asp:TextBox ID="txtTitle" runat="server" MaxLength="200" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                ErrorMessage="Title is required." CssClass="alert"
                Display="Dynamic" ValidationGroup="Upload" />
        </div>
        <div class="form-row">
            <label>Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
        </div>
        <div class="form-row">
            <label>File (PDF, JPEG, PNG, MP4, ZIP, DOCX — max 10 MB)</label>
            <asp:FileUpload ID="fileUpload" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="fileUpload"
                ErrorMessage="Please choose a file." CssClass="alert"
                Display="Dynamic" ValidationGroup="Upload" />
        </div>
        <asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="btn btn-primary"
            OnClick="btnUpload_Click" ValidationGroup="Upload" />
    </div>

    <h3>My Work</h3>
    <asp:Repeater ID="rptMine" runat="server" OnItemCommand="rptMine_ItemCommand">
        <HeaderTemplate><div class="gallery"></HeaderTemplate>
        <ItemTemplate>
            <div class="card card-sm p-item">
                <asp:Literal runat="server" Text='<%# RenderThumb(Eval("FileURL")) %>' />
                <strong><%# Server.HtmlEncode(Eval("Title").ToString()) %></strong>
                <%# (bool)Eval("IsFeatured") ? "<span class='badge'>Featured</span>" : "" %>
                <div class="p-meta">
                    <%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %>
                    &middot; <%# Eval("LikeCountT") %> likes
                    &middot; <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %>
                </div>
                <div class="p-actions">
                    <asp:Button runat="server" Text="Delete" CommandName="DeleteItem"
                        CommandArgument='<%# Eval("PortfolioID") %>' CssClass="btn"
                        OnClientClick="return confirm('Delete this item?');" CausesValidation="false" />
                    <asp:Button runat="server"
                        Text='<%# (bool)Eval("IsFeatured") ? "Unfeature" : "Feature" %>'
                        CommandName="ToggleFeature" CommandArgument='<%# Eval("PortfolioID") %>'
                        CssClass="btn" CausesValidation="false" />
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
    <asp:Panel ID="pnlNoMine" runat="server" Visible="false" CssClass="alert">
        You haven't uploaded any work yet.
    </asp:Panel>

    <h3>Community Gallery</h3>
    <asp:Repeater ID="rptGallery" runat="server" OnItemCommand="rptGallery_ItemCommand">
        <HeaderTemplate><div class="gallery"></HeaderTemplate>
        <ItemTemplate>
            <div class="card card-sm p-item">
                <asp:Literal runat="server" Text='<%# RenderThumb(Eval("FileURL")) %>' />
                <strong><%# Server.HtmlEncode(Eval("Title").ToString()) %></strong>
                <%# (bool)Eval("IsFeatured") ? "<span class='badge'>Featured</span>" : "" %>
                <div class="p-meta">
                    by <%# Server.HtmlEncode(Eval("FullName").ToString()) %>
                    &middot; <%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %>
                    &middot; <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %>
                </div>
                <div class="p-actions">
                    <asp:Button runat="server" Text='<%# "Like (" + Eval("LikeCountT") + ")" %>'
                        CommandName="LikeItem" CommandArgument='<%# Eval("PortfolioID") %>'
                        CssClass="btn" CausesValidation="false" />
                    <a class="btn" href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' target="_blank">View File</a>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
    <asp:Panel ID="pnlNoGallery" runat="server" Visible="false" CssClass="alert">
        No work has been shared yet.
    </asp:Panel>
</asp:Content>
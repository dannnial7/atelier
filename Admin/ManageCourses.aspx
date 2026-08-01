<%@ Page Title="Manage Courses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageCourses.aspx.cs" Inherits="Atelier.Admin.ManageCourses" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-wrapper {
            display: flex;
            min-height: calc(100vh - 120px);
        }
        .admin-sidebar {
            width: 220px;
            background-color: #4A1020;
            padding: 24px 0;
            flex-shrink: 0;
        }
        .admin-sidebar h3 {
            color: #BFCFE8;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            padding: 0 20px;
            margin-bottom: 12px;
        }
        .admin-sidebar a {
            display: block;
            padding: 10px 20px;
            color: rgba(191,207,232,0.75);
            font-size: 14px;
            text-decoration: none;
        }
        .admin-sidebar a:hover,
        .admin-sidebar a.active {
            background-color: #6B1A2A;
            color: #BFCFE8;
            text-decoration: none;
        }
        .admin-main {
            flex: 1;
            padding: 32px 40px;
            background-color: #F0F4F9;
        }
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }
        .form-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            display: none;
        }
        .form-panel.show {
            display: block;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .table-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
        }
        .course-img {
            width: 60px;
            height: 40px;
            object-fit: cover;
            border-radius: 4px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent"  runat="server">
    <div class="admin-wrapper">
        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server" class="active">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrollments.aspx" runat="server">Enrolments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">

                   <div class="page-header">
                <h2>Manage Courses</h2>
                <asp:Button ID="btnShowAdd" 
                    runat="server" 
                    Text="+ Add New Course"
                    CssClass="btn btn-primary"
                    OnClick="btnShowAdd_Click"/>
            </div>

                   <asp:Label ID="lblMessage" 
                    runat="server" 
                    Visible="false"
                    CssClass="alert alert-success"
                    style="display:block;margin-bottom:16px"/>

                <div class="form-panel" id="formPanel" 
                     runat="server">
                    <h3 style="margin-bottom:16px">
                        <asp:Label ID="lblFormTitle" 
                            runat="server" 
                            Text="Add New Course"/>
                    </h3>

                <asp:HiddenField ID="hdnCourseID" 
                    runat="server" Value="0"/>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Course Title</label>
                            <asp:TextBox ID="txtTitle" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtTitle"
                                ErrorMessage="Title is required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="CourseForm"/>
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <asp:DropDownList ID="ddlCategory" 
                            runat="server"/>
                        <asp:RequiredFieldValidator
                            runat="server"
                            ControlToValidate="ddlCategory"
                            InitialValue="0"
                            ErrorMessage="Please select a category"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="CourseForm"/>
                    </div>
                </div>

                <div class="form-group">
                    <label>Description</label>
                    <asp:TextBox ID="txtDescription" 
                        runat="server" 
                        TextMode="MultiLine" 
                        Rows="4"/>
                    <asp:RequiredFieldValidator
                        runat="server"
                        ControlToValidate="txtDescription"
                        ErrorMessage="Description is required"
                        CssClass="field-error"
                        Display="Dynamic"
                        ValidationGroup="CourseForm"/>
                </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Price (RM)</label>
                            <asp:TextBox ID="txtPrice" 
                                runat="server" 
                                Text="0.00"/>
                                <asp:RequiredFieldValidator
                                    runat="server"
                                    ControlToValidate="txtPrice"
                                    ErrorMessage="Price is required"
                                    CssClass="field-error"
                                    Display="Dynamic"
                                    ValidationGroup="CourseForm"/>
                                <asp:RangeValidator
                                    runat="server"
                                    ControlToValidate="txtPrice"
                                    MinimumValue="0"
                                    MaximumValue="9999"
                                    Type="Double"
                                    ErrorMessage="Price must be between 0 and 9999"
                                    CssClass="field-error"
                                    Display="Dynamic"
                                    ValidationGroup="CourseForm"/>
                    </div>
                    <div class="form-group">
                        <label>Difficulty</label>
                        <asp:DropDownList ID="ddlDifficulty" 
                            runat="server">
                            <asp:ListItem Value="Beginner">Beginner</asp:ListItem>
                            <asp:ListItem Value="Intermediate">Intermediate</asp:ListItem>
                            <asp:ListItem Value="Advanced">Advanced</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label style="margin-bottom:8px;font-weight:600;display:block;">Course Thumbnail</label>
                        <div style="display:flex;gap:20px;align-items:center;margin-bottom:10px;">
                            <label style="font-weight:normal;font-size:13.5px;cursor:pointer;display:inline-flex;align-items:center;gap:6px;margin:0;">
                                <input type="radio" name="thumbSource" id="radioSelect" checked="checked" onclick="toggleThumbSource('select')" style="margin:0;cursor:pointer;" />
                                <span>Choose Existing Image</span>
                            </label>
                            <label style="font-weight:normal;font-size:13.5px;cursor:pointer;display:inline-flex;align-items:center;gap:6px;margin:0;">
                                <input type="radio" name="thumbSource" id="radioUpload" onclick="toggleThumbSource('upload')" style="margin:0;cursor:pointer;" />
                                <span>Upload New Image</span>
                            </label>
                        </div>
                        <div id="thumbSelectGroup">
                            <asp:DropDownList ID="ddlExistingThumbnail" runat="server" CssClass="form-control" />
                        </div>
                        <div id="thumbUploadGroup" style="display:none;margin-top:4px;">
                            <asp:FileUpload ID="fuThumbnail" runat="server" CssClass="form-control" />
                            <span style="font-size:12px;color:var(--muted-colour);display:block;margin-top:4px;">Supported: JPG, PNG, WEBP</span>
                        </div>
                        <asp:TextBox ID="txtThumbnail" runat="server" style="display:none;" />
                    </div>
                    <div class="form-group" style="display:flex;flex-direction:column;justify-content:flex-start;">
                        <label style="margin-bottom:12px;font-weight:600;display:block;">Published Status</label>
                        <div style="display:inline-flex;align-items:center;gap:8px;">
                            <asp:CheckBox ID="chkPublished" runat="server" Checked="true" style="margin:0;cursor:pointer;width:16px;height:16px;" />
                            <asp:Label runat="server" AssociatedControlID="chkPublished" style="cursor:pointer;font-weight:500;margin:0;font-size:14px;color:var(--text-color);">Publish this course</asp:Label>
                        </div>
                    </div>
                </div>

                <div style="display:flex;gap:12px;margin-top:12px">
                    <asp:Button ID="btnSave" 
                        runat="server" 
                        Text="Save Course"
                        CssClass="btn btn-primary"
                        OnClick="btnSave_Click"
                        OnClientClick="return checkPublishConfirmation();"
                        ValidationGroup="CourseForm"/>
                    <asp:Button ID="btnCancel" 
                        runat="server" 
                        Text="Cancel"
                        CssClass="btn btn-secondary"
                        OnClick="btnCancel_Click"
                        CausesValidation="false"/>
                </div>
            </div>

            <script type="text/javascript">
                function toggleThumbSource(mode) {
                    var selGroup = document.getElementById('thumbSelectGroup');
                    var uplGroup = document.getElementById('thumbUploadGroup');
                    if (mode === 'upload') {
                        if (selGroup) selGroup.style.display = 'none';
                        if (uplGroup) uplGroup.style.display = 'block';
                    } else {
                        if (selGroup) selGroup.style.display = 'block';
                        if (uplGroup) uplGroup.style.display = 'none';
                    }
                }

                function checkPublishConfirmation() {
                    if (typeof Page_ClientValidate === 'function') {
                        if (!Page_ClientValidate('CourseForm')) return false;
                    }
                    var chk = document.getElementById('<%= chkPublished.ClientID %>');
                    if (chk && chk.checked) {
                        return confirm('Are you sure you want to publish this course to learners?');
                    }
                    return true;
                }
            </script>

            <div class="table-panel">
                <h3 style="margin-bottom:16px">
                    All Courses
                    <span class="badge badge-info" 
                          style="margin-left:8px">
                        <asp:Label ID="lblCourseCount" 
                            runat="server" Text="0"/>
                    </span>
                </h3>

                <div style="display:flex;gap:12px;margin-bottom:16px">
                    <asp:TextBox ID="txtSearch" 
                        runat="server" 
                        placeholder="Search by title or category..."/>
                    <asp:Button ID="btnSearch" 
                        runat="server" 
                        Text="Search"
                        CssClass="btn btn-primary"
                        OnClick="btnSearch_Click"
                        CausesValidation="false"/>
                    <asp:Button ID="btnReset" 
                        runat="server" 
                        Text="Reset"
                        CssClass="btn btn-secondary"
                        OnClick="btnReset_Click"
                        CausesValidation="false"/>
                </div>

                <asp:GridView ID="gvCourses" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvCourses_RowCommand"
                    EmptyDataText="No courses found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="CourseID" 
                            HeaderText="ID"/>
                        <asp:TemplateField HeaderText="Thumbnail">
                            <ItemTemplate>
                                <div style="display:flex;align-items:center;gap:10px;">
                                    <asp:Image runat="server"
                                        ImageUrl='<%# Eval("Thumbnail") %>'
                                        CssClass="course-img"
                                        AlternateText="thumbnail"
                                        onerror="this.onerror=null;this.src='../Images/Courses/Visual-Arts.jpg';" />
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Title" 
                            HeaderText="Title"/>
                        <asp:BoundField DataField="CategoryName" 
                            HeaderText="Category"/>
                        <asp:BoundField DataField="Price" 
                            HeaderText="Price (RM)"
                            DataFormatString="{0:F2}"/>
                        <asp:BoundField DataField="Difficulty" 
                            HeaderText="Difficulty"/>
                        <asp:TemplateField HeaderText="Published">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsPublished")) ? "badge badge-success" : "badge badge-warning" %>'>
                                    <%# Convert.ToBoolean(Eval("IsPublished")) ? "Published" : "Draft" %>
                                </span>
                            </ItemTemplate>  </asp:TemplateField>
                            <asp:BoundField DataField="EnrollmentCount" 
                              HeaderText="Enrollments"/>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="EditCourse" CommandArgument='<%# Eval("CourseID") %>'
                                    CssClass="btn btn-secondary btn-sm"
                                    CausesValidation="false">
                                    Edit
                                </asp:LinkButton>
                                <asp:LinkButton  runat="server" CommandName="DeleteCourse"
                                    CommandArgument='<%# Eval("CourseID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    CausesValidation="false"
                                    OnClientClick="if(!confirm('Are you sure you want to delete this course? This cannot be undone.')) return false;"> Delete
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>

</asp:Content>

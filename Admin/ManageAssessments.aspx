<%@ Page Title="Manage Assessments" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageAssessments.aspx.cs" Inherits="Atelier.Admin.ManageAssessments" %>
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
            margin-bottom: 24px;
        }
        .questions-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
            display: none;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
        <div class="admin-wrapper">

        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server" class="active">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrollments.aspx" runat="server">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">

            <div class="page-header">
                <h2>Manage Assessments</h2>
                <asp:Button ID="btnShowAdd" 
                    runat="server" 
                    Text="+ Add Assessment"
                    CssClass="btn btn-primary"
                    OnClick="btnShowAdd_Click"
                    CausesValidation="false"/>
            </div>

            <asp:Label ID="lblMessage" 
                runat="server" 
                Visible="false"
                style="display:block;margin-bottom:16px"/>

            <div class="form-panel" 
                 id="formPanel" runat="server">
                <h3 style="margin-bottom:16px">
                    <asp:Label ID="lblFormTitle" 
                        runat="server" 
                        Text="Add Assessment"/>
                </h3>

                <asp:HiddenField ID="hdnAssessmentID" 
                    runat="server" Value="0"/>

                <div class="form-row">
                    <div class="form-group">
                        <label>Course</label>
                        <asp:DropDownList 
                            ID="ddlCourse" 
                            runat="server"/>
                        <asp:RequiredFieldValidator
                            runat="server"
                            ControlToValidate="ddlCourse"
                            InitialValue="0"
                            ErrorMessage="Please select a course"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="AssessmentForm"/>
                    </div>
                    <div class="form-group">
                        <label>Assessment Title</label>
                        <asp:TextBox ID="txtTitle" 
                            runat="server"/>
                        <asp:RequiredFieldValidator
                            runat="server"
                            ControlToValidate="txtTitle"
                            ErrorMessage="Title is required"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="AssessmentForm"/>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Time Limit (minutes)</label>
                        <asp:TextBox ID="txtTimeLimit" 
                            runat="server" Text="30"/>
                        <asp:RangeValidator
                            runat="server"
                            ControlToValidate="txtTimeLimit"
                            MinimumValue="1"
                            MaximumValue="180"
                            Type="Integer"
                            ErrorMessage="Time must be between 1 and 180 minutes"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="AssessmentForm"/>
                    </div>
                    <div class="form-group">
                        <label>Pass Mark (%)</label>
                        <asp:TextBox ID="txtPassMark" 
                            runat="server" Text="60"/>
                        <asp:RangeValidator
                            runat="server"
                            ControlToValidate="txtPassMark"
                            MinimumValue="1"
                            MaximumValue="100"
                            Type="Integer"
                            ErrorMessage="Pass mark must be between 1 and 100"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="AssessmentForm"/>
                    </div>
                </div>

                <div class="form-group">
                    <label>Max Attempts</label>
                    <asp:TextBox ID="txtMaxAttempts" 
                        runat="server" Text="3"/>
                    <asp:RangeValidator
                        runat="server"
                        ControlToValidate="txtMaxAttempts"
                        MinimumValue="1"
                        MaximumValue="10"
                        Type="Integer"
                        ErrorMessage="Max attempts must be between 1 and 10"
                        CssClass="field-error"
                        Display="Dynamic"
                        ValidationGroup="AssessmentForm"/>
                </div>

                <div style="display:flex;gap:12px;margin-top:8px">
                    <asp:Button ID="btnSave" 
                        runat="server" 
                        Text="Save Assessment"
                        CssClass="btn btn-primary"
                        OnClick="btnSave_Click"
                        ValidationGroup="AssessmentForm"/>
                    <asp:Button ID="btnCancel" 
                        runat="server" 
                        Text="Cancel"
                        CssClass="btn btn-secondary"
                        OnClick="btnCancel_Click"
                        CausesValidation="false"/>
                </div>
            </div>
            <div class="table-panel">
                <h3 style="margin-bottom:16px">
                    All Assessments
                    <span class="badge badge-info" 
                          style="margin-left:8px">
                        <asp:Label ID="lblCount" 
                            runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvAssessments" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvAssessments_RowCommand"
                    EmptyDataText="No assessments found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="AssessmentID" 
                            HeaderText="ID"/>
                        <asp:BoundField DataField="CourseTitle" 
                            HeaderText="Course"/>
                        <asp:BoundField DataField="Title" 
                            HeaderText="Title"/>
                        <asp:BoundField DataField="TimeLimit" 
                            HeaderText="Time (mins)"/>
                        <asp:BoundField DataField="PassMark" 
                            HeaderText="Pass Mark (%)"/>
                        <asp:BoundField DataField="MaxAttempts" 
                            HeaderText="Max Attempts"/>
                        <asp:BoundField DataField="QuestionCount" 
                            HeaderText="Questions"/>
                        <asp:TemplateField HeaderText="Actions">
           <ItemTemplate>
            <div style="display:flex;
                        flex-direction:column;
                        gap:4px">
                <asp:LinkButton 
                    runat="server"
                    CommandName="EditAssessment"
                    CommandArgument='<%# Eval("AssessmentID") %>'
                    CssClass="btn btn-secondary btn-sm"
                    CausesValidation="false">
                    Edit
                </asp:LinkButton>
                <asp:LinkButton 
                    runat="server"
                    CommandName="ManageQuestions"
                    CommandArgument='<%# Eval("AssessmentID") %>'
                    CssClass="btn btn-accent btn-sm"
                    CausesValidation="false">
                    Questions
                </asp:LinkButton>
                <asp:LinkButton 
                    runat="server"
                    CommandName="DeleteAssessment"
                    CommandArgument='<%# Eval("AssessmentID") %>'
                    CssClass="btn btn-danger btn-sm"
                    CausesValidation="false"
                    OnClientClick="if(!confirm('Delete this assessment?')) return false;">
                    Delete
                </asp:LinkButton>
            </div>
        </ItemTemplate>
    </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div class="questions-panel" 
                 id="questionsPanel" runat="server">

                <asp:HiddenField ID="hdnSelectedAssessmentID" 
                    runat="server" Value="0"/>

                <h3 style="margin-bottom:4px">
                    Questions for: 
                    <asp:Label ID="lblAssessmentName" 
                        runat="server"/>
                </h3>
                <p style="color:#5A3A42;
                          font-size:13px;
                          margin-bottom:16px">
                    Each question needs exactly 
                    4 options with one correct answer.
                </p>

                <div style="background:#F0F4F9;
                            border-radius:10px;
                            padding:16px;
                            margin-bottom:16px">
                    <h4 style="margin-bottom:12px">
                        Add New Question
                    </h4>
                    <div class="form-group">
                        <label>Question Text</label>
                        <asp:TextBox ID="txtQuestion" 
                            runat="server" 
                            TextMode="MultiLine" 
                            Rows="2"/>
                        <asp:RequiredFieldValidator
                            runat="server"
                            ControlToValidate="txtQuestion"
                            ErrorMessage="Question text is required"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="QuestionForm"/>
                    </div>

                    <div style="display:grid;
                                grid-template-columns:1fr 1fr;
                                gap:12px;margin-bottom:12px">
                        <div class="form-group">
                            <label>Option A</label>
                            <asp:TextBox ID="txtOptionA" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtOptionA"
                                ErrorMessage="Option A required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="QuestionForm"/>
                        </div>
                        <div class="form-group">
                            <label>Option B</label>
                            <asp:TextBox ID="txtOptionB" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtOptionB"
                                ErrorMessage="Option B required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="QuestionForm"/>
                        </div>
                        <div class="form-group">
                            <label>Option C</label>
                            <asp:TextBox ID="txtOptionC" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtOptionC"
                                ErrorMessage="Option C required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="QuestionForm"/>
                        </div>
                        <div class="form-group">
                            <label>Option D</label>
                            <asp:TextBox ID="txtOptionD" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtOptionD"
                                ErrorMessage="Option D required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="QuestionForm"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Correct Answer</label>
                        <asp:DropDownList 
                            ID="ddlCorrectAnswer" 
                            runat="server">
                            <asp:ListItem Value="A">Option A</asp:ListItem>
                            <asp:ListItem Value="B">Option B</asp:ListItem>
                            <asp:ListItem Value="C">Option C</asp:ListItem>
                            <asp:ListItem Value="D">Option D</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <asp:Button ID="btnAddQuestion" 
                        runat="server" 
                        Text="Add Question"
                        CssClass="btn btn-primary"
                        OnClick="btnAddQuestion_Click"
                        ValidationGroup="QuestionForm"/>
                </div>
                <asp:GridView ID="gvQuestions" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvQuestions_RowCommand"
                    EmptyDataText="No questions yet."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="QuestionID" 
                            HeaderText="ID"/>
                        <asp:BoundField DataField="QuestionText" 
                            HeaderText="Question"/>
                        <asp:BoundField DataField="OrderIndex" 
                            HeaderText="Order"/>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton 
                                    runat="server"
                                    CommandName="DeleteQuestion"
                                    CommandArgument='<%# Eval("QuestionID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    CausesValidation="false"
                                    OnClientClick="if(!confirm('Delete this question?')) return false;">
                                    Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <asp:Button ID="btnCloseQuestions" 
                    runat="server" 
                    Text="Close"
                    CssClass="btn btn-secondary"
                    style="margin-top:16px"
                    OnClick="btnCloseQuestions_Click"
                    CausesValidation="false"/>
            </div>

        </div>
    </div>

</asp:Content>

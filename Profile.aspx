<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="Atelier.Profile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .profile-pic {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #6B1A2A;
        }
        .profile-grid {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 32px;
            align-items: start;
        }
        @media (max-width: 600px) {
            .profile-grid { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <asp:Panel ID="pnlPublicProfile" runat="server" Visible="false">
            <p><a href="Leaderboard.aspx">&larr; Back to Leaderboard</a></p>
            <div class="card" style="margin-top:16px;padding:32px;">
                <div style="text-align:center;">
                    <asp:Image ID="imgPublicAvatar" runat="server" CssClass="profile-pic" style="width:120px;height:120px;margin-bottom:16px;" />
                    <h2 style="font-size:28px;font-weight:700;margin:0 0 8px 0;"><asp:Literal ID="litPublicName" runat="server" /></h2>
                    <p style="font-size:15px;color:var(--muted-colour);max-width:500px;margin:0 auto 24px auto;">
                        <asp:Literal ID="litPublicBio" runat="server" />
                    </p>
                </div>

                <div class="grid-stats" style="max-width:650px;margin:0 auto 32px auto;">
                    <div class="stat-card" style="padding:16px;border-radius:12px;text-align:center;">
                        <asp:Label ID="lblPublicXP" runat="server" CssClass="stat-number" style="font-size:24px;font-weight:700;color:#6B1A2A;" />
                        <div style="font-size:13px;color:var(--muted-colour);margin-top:4px;">Total Experience Points</div>
                    </div>
                    <div class="stat-card" style="padding:16px;border-radius:12px;text-align:center;">
                        <asp:Label ID="lblPublicBadges" runat="server" CssClass="stat-number" style="font-size:24px;font-weight:700;color:#059669;" />
                        <div style="font-size:13px;color:var(--muted-colour);margin-top:4px;">Badges Earned</div>
                    </div>
                    <div class="stat-card" style="padding:16px;border-radius:12px;text-align:center;">
                        <asp:Label ID="lblPublicCourses" runat="server" CssClass="stat-number" style="font-size:24px;font-weight:700;color:#0284c7;" />
                        <div style="font-size:13px;color:var(--muted-colour);margin-top:4px;">Enrolled Courses</div>
                    </div>
                </div>

                <h3 style="text-align:left;font-size:18px;font-weight:700;margin-bottom:16px;">Enrolled Courses</h3>
                <asp:Repeater ID="rptPublicCourses" runat="server">
                    <HeaderTemplate><div class="grid-courses"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="course-card">
                            <img src='<%# Eval("Thumbnail") %>' class="course-thumbnail" alt='<%# Eval("Title") %>' />
                            <div class="course-body" style="text-align:left;">
                                <p class="course-title"><%# Eval("Title") %></p>
                                <p class="course-meta"><%# Eval("CategoryName") %></p>
                                <a href='<%# "CourseDetail.aspx?id=" + Eval("CourseID") %>' class="btn btn-primary btn-sm" style="margin-top:8px;display:block;text-align:center;">View Course</a>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoPublicCourses" runat="server" Visible="false">
                    <div class="alert alert-info">This learner has not enrolled in any public courses yet.</div>
                </asp:Panel>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlOwnProfile" runat="server">
            <h1>My Profile</h1>
            <p style="color:var(--muted-colour)">Manage your account details.</p>

            <asp:Panel ID="pnlSaved" runat="server" Visible="false">
                <div class="alert alert-success">
                    <asp:Literal ID="litSavedMsg" runat="server" />
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="alert alert-danger">
                    <asp:Literal ID="litErrorMsg" runat="server" />
                </div>
            </asp:Panel>

            <%-- Account details --%>
            <div class="card" style="margin-top:24px">
                <h2 class="section-title">Account Details</h2>

            <div class="profile-grid" style="margin-top:20px">

                <div style="text-align:center">
                    <asp:Image ID="imgProfile" runat="server" CssClass="profile-pic" />
                    <div class="form-group" style="margin-top:12px">
                        <asp:FileUpload ID="fuProfilePic" runat="server" />
                    </div>
                    <p class="course-meta" style="font-size:12px">
                        JPG or PNG, under 2 MB.
                    </p>
                </div>

                <div>
                    <div class="form-group">
                        <label>Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" />
                        <asp:RequiredFieldValidator runat="server"
                            ControlToValidate="txtFullName"
                            ErrorMessage="Full name is required."
                            ValidationGroup="Details"
                            CssClass="alert alert-danger"
                            Display="Dynamic" />
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
                        <asp:RequiredFieldValidator runat="server"
                            ControlToValidate="txtEmail"
                            ErrorMessage="Email is required."
                            ValidationGroup="Details"
                            CssClass="alert alert-danger"
                            Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server"
                            ControlToValidate="txtEmail"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                            ErrorMessage="Please enter a valid email address."
                            ValidationGroup="Details"
                            CssClass="alert alert-danger"
                            Display="Dynamic" />
                    </div>

                    <div class="form-group">
                        <label>Bio</label>
                        <asp:TextBox ID="txtBio" runat="server"
                            TextMode="MultiLine" Rows="4"
                            placeholder="Tell other learners about yourself..." />
                    </div>

                    <div class="form-group">
                        <label>Theme Preference</label>
                        <asp:DropDownList ID="ddlTheme" runat="server">
                            <asp:ListItem Value="light" Text="Light" />
                            <asp:ListItem Value="dark" Text="Dark" />
                        </asp:DropDownList>
                    </div>

                    <asp:Button ID="btnSaveDetails" runat="server"
                        Text="Save Changes"
                        CssClass="btn btn-primary"
                        ValidationGroup="Details"
                        OnClick="btnSaveDetails_Click" />
                </div>

            </div>
        </div>

        <%-- Password change, kept separate so a details update does not
             require re-entering the password --%>
        <div class="card" style="margin-top:24px">
            <h2 class="section-title">Change Password</h2>

            <div class="form-group" style="margin-top:16px">
                <label>Current Password</label>
                <asp:TextBox ID="txtCurrentPwd" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtCurrentPwd"
                    ErrorMessage="Enter your current password."
                    ValidationGroup="Password"
                    CssClass="alert alert-danger"
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>New Password</label>
                <asp:TextBox ID="txtNewPwd" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtNewPwd"
                    ErrorMessage="Enter a new password."
                    ValidationGroup="Password"
                    CssClass="alert alert-danger"
                    Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server"
                    ControlToValidate="txtNewPwd"
                    ValidationExpression=".{6,}"
                    ErrorMessage="Password must be at least 6 characters."
                    ValidationGroup="Password"
                    CssClass="alert alert-danger"
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Confirm New Password</label>
                <asp:TextBox ID="txtConfirmPwd" runat="server" TextMode="Password" />
                <asp:CompareValidator runat="server"
                    ControlToValidate="txtConfirmPwd"
                    ControlToCompare="txtNewPwd"
                    ErrorMessage="Passwords do not match."
                    ValidationGroup="Password"
                    CssClass="alert alert-danger"
                    Display="Dynamic" />
            </div>

            <asp:Button ID="btnChangePwd" runat="server"
                Text="Update Password"
                CssClass="btn btn-secondary"
                ValidationGroup="Password"
                OnClick="btnChangePwd_Click" />
        </div>

        <%-- Billing & Saved Payment Method --%>
        <div class="card" style="margin-top:24px">
            <h2 class="section-title">Billing Account & Payment Setup</h2>
            <p style="color:var(--muted-colour);margin-bottom:16px">
                Set up your billing details to auto-fill payment forms during course enrollment.
            </p>

            <asp:Panel ID="pnlBillingSaved" runat="server" Visible="false">
                <div class="alert alert-success">
                    <asp:Literal ID="litBillingSavedMsg" runat="server" />
                </div>
            </asp:Panel>

            <div class="form-group">
                <label>Cardholder / Billing Name</label>
                <asp:TextBox ID="txtBillingName" runat="server" placeholder="Full name on card" />
            </div>

            <div class="form-group">
                <label>Billing Address</label>
                <asp:TextBox ID="txtBillingAddress" runat="server" placeholder="Street address, City, Country" />
            </div>

            <div class="form-row" style="display:flex;gap:16px">
                <div class="form-group" style="flex:2">
                    <label>Saved Card Number</label>
                    <asp:TextBox ID="txtSavedCardNumber" runat="server" placeholder="1234 5678 9012 3456" MaxLength="16" />
                </div>
                <div class="form-group" style="flex:1">
                    <label>Expiry Date (MM/YY)</label>
                    <asp:TextBox ID="txtSavedExpiry" runat="server" placeholder="MM/YY" MaxLength="5" />
                </div>
            </div>

            <asp:Button ID="btnSaveBilling" runat="server"
                Text="Save Billing Details"
                CssClass="btn btn-primary"
                OnClick="btnSaveBilling_Click" />
        </div>

        <%-- Payment History --%>
        <div class="card" style="margin-top:24px">
            <h2 class="section-title">Payment History</h2>
            <p style="color:var(--muted-colour);margin-bottom:16px">
                View your past course enrollments and transaction receipts.
            </p>

            <asp:Panel ID="pnlNoPayments" runat="server" Visible="false">
                <div class="alert alert-info">
                    No payment history found. <a href="~/Courses.aspx" runat="server">Browse our course catalogue</a> to enroll!
                </div>
            </asp:Panel>

            <asp:Repeater ID="rptPaymentHistory" runat="server">
                <HeaderTemplate>
                    <table class="table" style="width:100%;border-collapse:collapse;margin-top:12px">
                        <thead>
                            <tr style="border-bottom:2px solid var(--border-colour);text-align:left;font-size:14px;color:var(--muted-colour)">
                                <th style="padding:10px 8px">Course</th>
                                <th style="padding:10px 8px">Amount</th>
                                <th style="padding:10px 8px">Date</th>
                                <th style="padding:10px 8px">Card Used</th>
                                <th style="padding:10px 8px">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr style="border-bottom:1px solid var(--border-colour);font-size:14px">
                        <td style="padding:12px 8px"><strong><%# Eval("CourseTitle") %></strong></td>
                        <td style="padding:12px 8px">
                            <%# Convert.ToDecimal(Eval("Amount")) == 0 ? "<span style='color:var(--accent-colour);font-weight:600'>Free</span>" : "RM " + Convert.ToDecimal(Eval("Amount")).ToString("F2") %>
                        </td>
                        <td style="padding:12px 8px"><%# Convert.ToDateTime(Eval("PaidAt")).ToString("dd MMM yyyy, hh:mm tt") %></td>
                        <td style="padding:12px 8px">
                            <%# Eval("Cardlastdigits").ToString() == "FREE" ? "Free Enrollment" : "**** " + Eval("Cardlastdigits") %>
                        </td>
                        <td style="padding:12px 8px"><span class="badge badge-success"><%# Eval("Status") %></span></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
        </asp:Panel>

    </div>

</asp:Content>
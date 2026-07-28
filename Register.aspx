<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="Atelier.Register" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="auth-wrapper">
        <div class="auth-card card">

            <h1 style="text-align:center;margin-bottom:8px">Create Account</h1>
            <p style="text-align:center;color:var(--muted-colour);margin-bottom:24px">
                Join Atelier and start your creative journey today.
            </p>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="alert alert-danger">
                    <asp:Literal ID="litError" runat="server" />
                </div>
            </asp:Panel>

            <div class="form-group">
                <label>Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server"
                    placeholder="e.g. John Doe" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtFullName"
                    ErrorMessage="Full name is required."
                    ValidationGroup="Register"
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                    placeholder="you@example.com" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="Email is required."
                    ValidationGroup="Register"
                    CssClass="field-error"
                    Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email address."
                    ValidationGroup="Register"
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                    placeholder="Minimum 6 characters" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Password is required."
                    ValidationGroup="Register"
                    CssClass="field-error"
                    Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server"
                    ControlToValidate="txtPassword"
                    ValidationExpression=".{6,}"
                    ErrorMessage="Password must be at least 6 characters."
                    ValidationGroup="Register"
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Confirm Password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                    placeholder="Re-enter your password" />
                <asp:CompareValidator runat="server"
                    ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtPassword"
                    ErrorMessage="Passwords do not match."
                    ValidationGroup="Register"
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <asp:Button ID="btnRegister" runat="server"
                Text="Create Account"
                CssClass="btn btn-primary btn-lg"
                style="width:100%;margin-top:8px"
                ValidationGroup="Register"
                OnClick="btnRegister_Click" />

            <div style="text-align:center;margin-top:16px;font-size:14px">
                Already have an account?
                <a id="lnkLoginLink" href="~/Login.aspx" runat="server" style="font-weight:600">
                    Sign in
                </a>
            </div>

        </div>
    </div>

</asp:Content>

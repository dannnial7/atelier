<%@ Page Title="Sign In" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Atelier.Login" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="auth-wrapper">
        <div class="auth-card card">

            <h1 style="text-align:center;margin-bottom:8px">Welcome Back</h1>
            <p style="text-align:center;color:var(--muted-colour);margin-bottom:24px">
                Sign in to continue your creative journey.
            </p>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="alert alert-danger">
                    <asp:Literal ID="litError" runat="server" />
                </div>
            </asp:Panel>

            <div class="form-group">
                <label>Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                    placeholder="you@example.com" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="Email is required."
                    ValidationGroup="Login"
                    CssClass="field-error"
                    Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email."
                    ValidationGroup="Login"
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                    placeholder="Enter your password" />
                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Password is required."
                    ValidationGroup="Login"
                    CssClass="field-error"
                    Display="Dynamic" />
            </div>

            <asp:Button ID="btnLogin" runat="server"
                Text="Sign In"
                CssClass="btn btn-primary btn-lg"
                style="width:100%;margin-top:8px"
                ValidationGroup="Login"
                OnClick="btnLogin_Click" />

            <div style="text-align:center;margin-top:20px">
                <a href="~/ForgotPassword.aspx" runat="server"
                   style="font-size:13px;color:var(--muted-colour)">
                    Forgot your password?
                </a>
            </div>

            <div style="text-align:center;margin-top:16px;font-size:14px">
                Don't have an account?
                <a id="lnkRegisterLink" href="~/Register.aspx" runat="server" style="font-weight:600">
                    Register here
                </a>
            </div>

        </div>
    </div>

</asp:Content>

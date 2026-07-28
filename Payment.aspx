<%@ Page Title="Payment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="Atelier.Payment" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .payment-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 32px;
            align-items: start;
        }
        @media (max-width: 768px) {
            .payment-grid { grid-template-columns: 1fr; }
        }
        .order-summary {
            background: var(--surface-colour);
            border-radius: var(--radius-lg);
            padding: var(--space-lg);
        }
        .order-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            font-size: 14px;
        }
        .order-total {
            display: flex;
            justify-content: space-between;
            padding: 12px 0 0;
            margin-top: 8px;
            border-top: 1px solid var(--border-colour);
            font-weight: 600;
            font-size: 18px;
            color: #6B1A2A;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <h1>Payment</h1>
        <p style="color:var(--muted-colour);margin-bottom:32px">
            Complete your payment to enroll in the course.
        </p>

        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="alert alert-danger">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlAlreadyEnrolled" runat="server" Visible="false">
            <div class="alert alert-info">
                You are already enrolled in this course.
                <a href="~/Dashboard.aspx" runat="server">Go to Dashboard</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlPayment" runat="server">

            <div class="payment-grid">

                <%-- Card form --%>
                <div class="card">
                    <h2 class="section-title" style="margin-bottom:20px">Card Details</h2>

                    <asp:Panel ID="pnlCardInputs" runat="server">
                        <div class="form-group">
                            <label>Cardholder Name</label>
                            <asp:TextBox ID="txtCardName" runat="server"
                                placeholder="Name on card" />
                            <asp:RequiredFieldValidator runat="server"
                                ControlToValidate="txtCardName"
                                ErrorMessage="Cardholder name is required."
                                ValidationGroup="Pay"
                                CssClass="field-error"
                                Display="Dynamic" />
                        </div>

                        <div class="form-group">
                            <label>Card Number</label>
                            <asp:TextBox ID="txtCardNumber" runat="server"
                                placeholder="1234 5678 9012 3456"
                                MaxLength="16" />
                            <asp:RequiredFieldValidator runat="server"
                                ControlToValidate="txtCardNumber"
                                ErrorMessage="Card number is required."
                                ValidationGroup="Pay"
                                CssClass="field-error"
                                Display="Dynamic" />
                            <asp:RegularExpressionValidator runat="server"
                                ControlToValidate="txtCardNumber"
                                ValidationExpression="^\d{16}$"
                                ErrorMessage="Card number must be 16 digits."
                                ValidationGroup="Pay"
                                CssClass="field-error"
                                Display="Dynamic" />
                        </div>

                        <div style="display:flex;gap:16px">
                            <div class="form-group" style="flex:1">
                                <label>Expiry (MM/YY)</label>
                                <asp:TextBox ID="txtExpiry" runat="server"
                                    placeholder="MM/YY"
                                    MaxLength="5" />
                                <asp:RequiredFieldValidator runat="server"
                                    ControlToValidate="txtExpiry"
                                    ErrorMessage="Expiry is required."
                                    ValidationGroup="Pay"
                                    CssClass="field-error"
                                    Display="Dynamic" />
                                <asp:RegularExpressionValidator runat="server"
                                    ControlToValidate="txtExpiry"
                                    ValidationExpression="^(0[1-9]|1[0-2])\/\d{2}$"
                                    ErrorMessage="Format must be MM/YY."
                                    ValidationGroup="Pay"
                                    CssClass="field-error"
                                    Display="Dynamic" />
                            </div>

                            <div class="form-group" style="flex:1">
                                <label>CVV</label>
                                <asp:TextBox ID="txtCVV" runat="server"
                                    TextMode="Password"
                                    placeholder="123"
                                    MaxLength="4" />
                                <asp:RequiredFieldValidator runat="server"
                                    ControlToValidate="txtCVV"
                                    ErrorMessage="CVV is required."
                                    ValidationGroup="Pay"
                                    CssClass="field-error"
                                    Display="Dynamic" />
                                <asp:RegularExpressionValidator runat="server"
                                    ControlToValidate="txtCVV"
                                    ValidationExpression="^\d{3,4}$"
                                    ErrorMessage="3 or 4 digits."
                                    ValidationGroup="Pay"
                                    CssClass="field-error"
                                    Display="Dynamic" />
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:Button ID="btnPay" runat="server"
                        Text="Confirm Payment"
                        CssClass="btn btn-primary btn-lg"
                        style="width:100%;margin-top:12px"
                        ValidationGroup="Pay"
                        OnClick="btnPay_Click" />

                    <p style="text-align:center;font-size:12px;color:var(--muted-colour);margin-top:12px">
                        This is a simulated payment. No real charges will be made.
                    </p>
                </div>

                <%-- Order summary --%>
                <div class="order-summary">
                    <h3 style="margin-bottom:16px">Order Summary</h3>
                    <div class="order-row">
                        <span>Course</span>
                        <span><asp:Literal ID="litCourseTitle" runat="server" /></span>
                    </div>
                    <div class="order-row">
                        <span>Category</span>
                        <span style="color:var(--muted-colour)"><asp:Literal ID="litCategory" runat="server" /></span>
                    </div>
                    <div class="order-row">
                        <span>Difficulty</span>
                        <span style="color:var(--muted-colour)"><asp:Literal ID="litDifficulty" runat="server" /></span>
                    </div>
                    <div class="order-total">
                        <span>Total</span>
                        <span>RM <asp:Literal ID="litPrice" runat="server" /></span>
                    </div>
                </div>

            </div>

        </asp:Panel>

    </div>

</asp:Content>

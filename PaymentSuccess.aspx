<%@ Page Title="Payment Successful" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PaymentSuccess.aspx.cs" Inherits="Atelier.PaymentSuccess" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .success-wrapper {
            text-align: center;
            padding: 60px 20px;
            max-width: 600px;
            margin: 0 auto;
        }
        .success-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #D1FAE5;
            color: #065F46;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
        }
        .success-actions {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-top: 32px;
            flex-wrap: wrap;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="success-wrapper">

        <div class="success-icon">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#065F46" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
        </div>

        <h1>Payment Successful!</h1>
        <p style="color:var(--muted-colour);margin-top:12px;font-size:16px">
            You have been enrolled in
            <strong><asp:Literal ID="litCourseName" runat="server" /></strong>.
        </p>

        <div class="card" style="margin-top:24px;text-align:left">
            <div style="display:flex;justify-content:space-between;padding:8px 0">
                <span style="color:var(--muted-colour)">Course</span>
                <span><asp:Literal ID="litCourseTitle" runat="server" /></span>
            </div>
            <div style="display:flex;justify-content:space-between;padding:8px 0">
                <span style="color:var(--muted-colour)">Amount Paid</span>
                <span style="font-weight:600;color:#6B1A2A">
                    RM <asp:Literal ID="litAmount" runat="server" />
                </span>
            </div>
            <div style="display:flex;justify-content:space-between;padding:8px 0">
                <span style="color:var(--muted-colour)">Status</span>
                <span class="badge badge-success">Completed</span>
            </div>
        </div>

        <div class="success-actions">
            <a href='<%= "CourseDetail.aspx?id=" + Request.QueryString["courseId"] %>'
               class="btn btn-primary">
                Go to Course
            </a>
            <a href="~/Dashboard.aspx" runat="server" class="btn btn-secondary">
                Go to Dashboard
            </a>
        </div>

    </div>

</asp:Content>

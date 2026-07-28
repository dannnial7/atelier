USE AtelierDatabase;
GO

UPDATE Users SET PasswordHash = '$2a$11$wcpeOpDEjSiDRpxwt.HLdumLk6uFFOrUiyyPIpZSvplYSpvi03WcK' WHERE Email = 'admin@atelier.com';
UPDATE Users SET PasswordHash = '$2a$11$geHeVYIqmdjh51RZTBLBm.EXUNvGLXFrWMxHcn7Zb80UXDgbDooVu' WHERE Email = 'Roy@atelier.com';
UPDATE Users SET PasswordHash = '$2a$11$6gnPPj3POQWRPUcMN8D9ROyRPRAei8RHHJiw/ljkwM1xI0py.Nc3C' WHERE Email = 'Ethan@atelier.com';
UPDATE Users SET PasswordHash = '$2a$11$98a1ya.UEIRTzxQapFq0FuGp1bi3g.ssYIKQp33yruiVptYR1bWEO' WHERE Email = 'sarah@atelier.com';
UPDATE Users SET PasswordHash = '$2a$11$hldqzaH5vqbeUNM8LJYgI./FWyLgeG1xBho2bwePCs.uFTN/OhrzO' WHERE Email = 'Kim@atelier.com';
GO

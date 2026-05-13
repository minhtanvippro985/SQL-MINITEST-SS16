CREATE DATABASE dbdemo;
USE dbdemo;



CREATE TABLE Customers(
	Customer_ID VARCHAR(10) PRIMARY KEY,
    Full_Name VARCHAR(100),
    Phone_Number VARCHAR(20) UNIQUE ,
    Email VARCHAR(100) ,
    Register_Date DATE 
);


CREATE TABLE Internet_Packages(
	Package_ID VARCHAR(10) PRIMARY KEY,
    Package_Name VARCHAR(100),
    Max_Speed INT CHECK(Max_Speed > 0),
    Monthly_Fee INT 
    
);

CREATE TABLE Subscriptions(
	Subscription_ID VARCHAR(10) PRIMARY KEY ,
    Customer_ID VARCHAR(10) ,
    Package_ID VARCHAR(10),
    foreign key (Customer_ID) references Customers(Customer_ID),
	foreign key (Package_ID) references Internet_Packages(Package_ID),
    Start_Date DATE ,
    End_Date DATE ,
    Status VARCHAR(30)
    

);

CREATE TABLE Support_Tickets(
	Ticket_ID VARCHAR(30) PRIMARY KEY,
    Subscription_ID VARCHAR(10),
	foreign key (Subscription_ID) references Subscriptions(Subscription_ID),
    Created_Date DATE ,
    Issue_Content VARCHAR(500),
    Status VARCHAR(30)
    

);


CREATE TABLE Ticket_Processing_Log(
	Log_ID VARCHAR(50) PRIMARY KEY ,
    Ticket_ID VARCHAR(30),
	foreign key (Ticket_ID) references Support_Tickets(Ticket_ID),
    Action_Detail VARCHAR(50) ,
    Recorded_AT DATETIME,
    Processor VARCHAR(30)

);


INSERT INTO Customers(Customer_ID,Full_Name,Phone_Number,Email,Register_Date)
VALUES

('C001'	,'Nguyen Minh Quan','0901112233','quan.nm@gmail.com','2024-01-10'),
('C002','Tran Bao Chau','0988777666','chau.tb@yahoo.com','2024-04-15'),
('C003','Le Hoang Kiet','0903334455','kiet.lh@gmail.com','2025-03-20'),
('C004','Pham Gia Bao'	,'0355556677','bao.pg@outlook.com',	'2025-09-01'),
('C005','Hoang Minh Thu','0779998811','thu.hm@gmail.com','2026-02-01'),
('C006','Hdsadsdsadsau','122113321','tcu.hm@gmail.com','2026-02-01');



INSERT INTO Internet_Packages(Package_ID,Package_Name,Max_Speed,Monthly_Fee)
VALUES 
('PKG01' , 'Fiber Basic' , 100  , 250000 ),
('PKG02' , 'Fiber Premium' , 300  , 500000 ),
('PKG03' , 'Fiber Business' , 500  , 1200000 ),
('PKG04' , 'Gaming Ultra' , 1000  , 2000000 ),
('PKG05' , 'Home Economy' , 50  , 180000 )
;


INSERT INTO Subscriptions(Subscription_ID,Customer_ID,Package_ID,Start_Date,End_Date,Status)
VALUES 
('SUB101','C001','PKG01','2024-01-10','2025-01-10','Expired'),
('SUB102','C002','PKG02','2024-04-15','2026-04-15','Active'),
('SUB103','C003','PKG03','2025-03-20','2027-03-20','Active'),
('SUB104','C004','PKG05','2025-09-01','2026-09-01','Active'),
('SUB105','C005','PKG04','2026-02-01','2027-02-01','Active'),
('SUB106','C006','PKG01','2026-02-01','2025-02-01','Active');
;



INSERT INTO Support_Tickets(Ticket_ID,Subscription_ID,Created_Date,Issue_Content,Status)
VALUES
('TIC901' , 'SUB102' , '2024-06-01','Mat ket noi internet','Resolved'),
('TIC902' , 'SUB103' , '2025-05-10','Mang cham vao buoi','Pending'),
('TIC903' , 'SUB101' , '2024-11-15','Loi modem wifi','Resolved'),
('TIC904' , 'SUB104' , '2025-12-20','Khong vao duoc mang','Rejected'),
('TIC905' , 'SUB105' , '2026-03-05','Yeu cau nang cap modem','Pending');



INSERT INTO Ticket_Processing_Log(Log_ID,Ticket_ID,Action_Detail,Recorded_AT,Processor)
VALUES 
('L001','TIC901','Da kiem tra duong truyen','2024-06-01 09:00','Staff 01'),
('L002','TIC901','Hoan tat sua loi internet','2024-06-01 14:00','Staff 01'),
('L003','TIC902','Dang xu ly toc do mang','2025-05-11 10:30','Staff 02'),
('L004','TIC904','Tu choi ho tro do loi khach hang','2025-12-21 15:00','Staff_03'),
('L005','TIC905','Da tiep nhan yeu cau nang cap','2026-03-05 16:30','Staff_03');


-- Viet cau lenh tang gia cuoc hanh thang them 10% 
SELECT * from Internet_Packages;

UPDATE Internet_Packages
SET Monthly_Fee = Monthly_Fee * 1.1
WHERE Max_Speed > 300 ;


-- Viet cau lenh xoa cac nhat ky truoc 2025
DELETE FROM Ticket_Processing_Log
WHERE Recorded_AT < '2025-01-01';


-- liet ke cac subs co ket thuc vao 2027
SELECT * FROM Subscriptions
WHERE Status = 'Active' AND YEAR(End_Date) = '2027'  ;

-- Lay thong tin khach hang ho ten Email co ten chua chu hoang va dang ky dich vu tu 2025 tro lai

SELECT Full_Name , Email
FROM Customers
WHERE Full_Name LIKE '%Hoang%' 
AND Register_Date  > '2025-01-01';

-- Sap xep Monthly_Fee giam dan , bo qua ban ghi dau tien lay 3 ban ghi tiep theo 
SELECT * FROM Internet_Packages
ORDER BY Monthly_Fee DESC
LIMIT 3 
OFFSET 1;

-- left join de hien thi khac hang chua co yeu cau ho tro
SELECT C.Full_Name ,S.Start_Date, P.Package_Name , SP.Issue_Content
FROM Customers C
LEFT JOIN Subscriptions S ON S.Customer_ID = C.Customer_ID
LEFT JOIN Internet_Packages P ON S.Package_ID = P.Package_ID
LEFT JOIN Support_Tickets SP ON S.Subscription_ID = SP.Subscription_ID;

-- thong ke so luong yeu cau ho tro da xu ly thanh cong resolved

SELECT C.Full_Name , Count(Sp.Ticket_ID) resolved_request
FROM Customers C 
LEFT JOIN Subscriptions S ON C.Customer_ID = S.Customer_ID
LEFT JOIN Support_Tickets SP ON S.Subscription_ID = SP.Subscription_ID
WHERE SP.Status = 'Resolved'
GROUP BY C.Full_Name
HAVING resolved_request >= 1;

-- goi cuoc khac hang dang ky nhieu nhat 

SELECT I.Package_Name , COUNT(S.Package_ID) FROM Internet_Packages I
JOIN Subscriptions S ON S.Package_ID = I.Package_ID
GROUP BY I.Package_Name;


-- TAO INDEX 

CREATE INDEX idx_subscription_status_date ON Subscriptions(Status , Start_Date);



-- Trigger ngan chan viec xoa dang ky dich 

DELIMITER //

CREATE TRIGGER preventDeleteActive
BEFORE DELETE 
ON Subscriptions
FOR EACH ROW 

BEGIN 
	IF OLD.Status = 'Active' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong duoc xoa';
	END IF;

END //

DELIMITER ;
DROP TRIGGER preventDeleteActive;

DELETE FROM Subscriptions
WHERE Subscription_ID = 'SUB102'










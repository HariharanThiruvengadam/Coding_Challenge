
create database CarRentalSystem;

use CarRentalSystem;


create table vehicle (
vehicleId int identity(1,1) primary key not null,
make varchar(255),
model varchar(255),
[year] int,
dailyRate decimal(5,2),
availableStatus int constraint chk_Status check(availableStatus in(1,0)),
passengerCapacity int,
engineCapacity int
);

create table customer(
customerId int identity(1,1) primary key not null,
firstName varchar(255),
lastName varchar(255),
email varchar(255),
phoneNumber varchar(255)
);

create table lease(
leaseId int identity(1,1) primary key not null,
vehicleId int,
customerId int,
startDate DATE,
endDate DATE,
type varchar(255) constraint chk_Type check(type in('Daily','Monthly')),
foreign key (vehicleId) references vehicle(vehicleId),
foreign key (customerId) references customer(customerId)
);

create table Payment(
paymentId int identity(1,1) primary key not null,
leaseId int,
paymentDate date,
amount decimal(10,2)
);


insert into vehicle values ('Toyota','Camry',2022,50.00,1,4,1450),
( 'Honda' ,'Civic', 2023, 45.00, 1, 7, 1500) ,
( 'Ford', 'Focus' ,2022, 48.00 ,0, 4, 1400 ),
( 'Nissan', 'Altima',2023 ,52.00, 1, 7, 1200 ),
( 'Chevrolet' ,'Malibu', 2022, 47.00, 1, 4, 1800) ,
( 'Hyundai', 'Sonata', 2023 ,49.00 ,0, 7, 1400 ),
( 'BMW', '3 Series', 2023, 60.00, 1, 7, 2499),
( 'Mercedes', 'C-Class', 2022, 58.00, 1 ,8 ,2599), 
('Audi','A4', 2022 ,55.00 ,0 ,4, 2500 ),
( 'Lexus', 'ES', 2023 ,54.00, 1, 4, 2500);

insert into customer values('John','Doe','johndoe@example.com', 
'555-555-5555'),
('Jane' ,'Smith', 'janesmith@example.com' ,
'555-123-4567'), 
('Robert', 'Johnson' ,'robert@example.com', 
'555-789-1234' ),
('Sarah', 'Brown' ,'sarah@example.com', 
'555-456-7890' ),
('David' ,'Lee', 'david@example.com',
'555-987-6543'),
('Laura', 'Hall','laura@example.com', 
'555-234-5678' ),
('Michael', 'Davis' ,'michael@example.com', 
'555-876-5432' ),
('Emma', 'Wilson','emma@example.com', 
'555-432-1098' ),
('William', 'Taylor', 'william@example.com', 
'555-321-6547' ),
('Olivia', 'Adams', 'olivia@example.com', 
'555-765-4321');

insert into lease values (1,1,'2023-01-01','2023-01-05','Daily'),
( 2,2,'2023-02-15','2023-02-28','Monthly'),
( 3 ,3 ,'2023-03-10','2023-03-15','Daily' ),
( 4 ,4 ,'2023-04-20','2023-04-30','Monthly' ),
( 5 ,5 ,'2023-05-05', '2023-05-10','Daily' ),
( 4 ,3 ,'2023-06-15' ,'2023-06-30' ,'Monthly' ),
( 7 ,7 ,'2023-07-01' ,'2023-07-10' ,'Daily' ),
( 8 ,8 ,'2023-08-12' ,'2023-08-15', 'Monthly' ),
( 3 ,3 ,'2023-09-07', '2023-09-10' ,'Daily' ),
( 10 ,10, '2023-10-10', '2023-10-31','Monthly');


insert into payment values (1 ,'2023-01-03', 200.00),
(2,'2023-02-20' ,1000.00), 
(3, '2023-03-12', 75.00), 
(4,'2023-04-25',900.00),
(5,'2023-05-07',60.00),
(6 ,'2023-06-18', 1200.00),
(7,'2023-07-03' ,40.00), 
(8, '2023-08-12', 1100.00), 
(9,'2023-09-09',80.00),
(10,'2023-10-25',1600.00);


ALTER TABLE payment ADD CONSTRAINT fk_leaseID
FOREIGN KEY (leaseID) REFERENCES lease(leaseID) ON DELETE CASCADE



--dropped foreign key constraint and added for avoiding foreign key conflicts 
ALTER TABLE lease ADD CONSTRAINT fk_vehicleId
FOREIGN KEY (vehicleID) REFERENCES vehicle(vehicleID) ON DELETE CASCADE

ALTER TABLE lease ADD CONSTRAINT fk_customerID
FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE




--1. Update the daily rate for a Mercedes car to 68.
update vehicle set dailyRate = 68 where make='Mercedes';

--2. Delete a specific customer and all associated leases and payments.
delete from customer where customerId =2;


--3. Rename the "paymentDate" column in the Payment table to "transactionDate".
exec sp_rename 'payment.paymentDate' ,'transactionDate','COLUMN';

--4. Find a specific customer by email. 
select * from customer where email ='janesmith@example.com';

--5. Get active leases for a specific customer.
select * from lease where customerId = 2 and endDate>getDATE();

--6. Find all payments made by a customer with a specific phone number.
select * from payment p 
join lease l 
on p.leaseId = l.leaseId 
join customer c
on l.customerId = c.customerId
where phoneNumber = '555-555-5555';


--7. Calculate the average daily rate of all available cars. 
select make,avg(dailyRate) as AverageDailyRate from vehicle group by make;

--8. Find the car with the highest daily rate.
select top 1 make from vehicle order by dailyRate desc;

--9. Retrieve all cars leased by a specific customer. 
select * from vehicle v 
join lease l 
on v.vehicleId=l.vehicleId
join customer c
on c.customerId = l.leaseId
where concat(firstName,lastName) = 'JohnDoe';

--10. Find the details of the most recent lease. 
select  top 1 * from lease order by startDate desc;

--11. List all payments made in the year 2023.
select * from payment where year(transactionDate) =2023;

--12. Retrieve customers who have not made any payments. 
select * from customer c
left join lease l
on c.customerId=l.customerId
left join payment p 
on p.leaseId=l.leaseId
where p.leaseId is null;

--13. Retrieve Car Details and Their Total Payments. 
select v.vehicleId,make,model,sum(amount) as totalPayments from vehicle v
join lease l 
on v.vehicleId=l.vehicleId
join payment p
on l.leaseId=p.leaseId
group by  v.vehicleId,make,model;

--14. Calculate Total Payments for Each Customer. 
select concat(firstName,' ',lastname) as [Name], sum(amount) as totalPayments from customer c
join lease l
on c.customerId=l.customerId
join payment p 
on l.leaseId=p.leaseId
group by paymentId,firstName,lastName;


--15. List Car Details for Each Lease. 
select * from lease l
left join vehicle v
on l.vehicleId = v.vehicleId;

--16. Retrieve Details of Active Leases with Customer and Car Information. 
select * from lease l
join customer c
on l.customerId = c.customerId
join vehicle v
on v.vehicleId=l.vehicleId
where endDate>getdate();

--17. Find the Customer Who Has Spent the Most on Leases. 
select top 1 c.customerId,concat(firstName,' ',lastName) as [Name],sum(amount) as AmountSpent from customer c
join lease l
on c.customerId =l.customerId
join payment p
on p.leaseId = l.leaseId
group by c.customerId,firstName,lastName
order by sum(amount) desc;

--18. List All Cars with Their Current Lease Information. 
select * from vehicle v
join lease l
on v.vehicleId = l.leaseId;

﻿CREATE DATABASE QLGV_22520859
USE QLGV_22520859

-- Câu 1: Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại

-- Bảng KHOA
CREATE TABLE KHOA
(
	MAKHOA VARCHAR(4),
	TENKHOA VARCHAR(40),
	NGTLAP SMALLDATETIME,
	TRGKHOA CHAR(4), -- Mã giáo viên
	CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
)
GO

-- Bảng MONHOC
CREATE TABLE MONHOC
(
	MAMH VARCHAR(10),
	TENMH VARCHAR(40),
	TCLT TINYINT,
	TCTH TINYINT,
	MAKHOA VARCHAR(4),
	CONSTRAINT PK_MONHOC PRIMARY KEY (MAMH)
)
GO

-- Bảng DIEUKIEN
CREATE TABLE DIEUKIEN
(
	MAMH VARCHAR(10), -- Thuộc tính khoa
	MAMH_TRUOC VARCHAR(10), -- Thuộc tính khoa
	CONSTRAINT PK_DIEUKIEN PRIMARY KEY (MAMH, MAMH_TRUOC)
)
GO

-- Bảng GIAOVIEN
CREATE TABLE GIAOVIEN
(
	MAGV CHAR(4),
	HOTEN VARCHAR(40),
	HOCVI VARCHAR(10),
	HOCHAM VARCHAR(10),
	GIOITINH VARCHAR(3),
	NGSINH SMALLDATETIME,
	NGVL SMALLDATETIME,
	HESO NUMERIC(4,2),
	MUCLUONG MONEY,
	MAKHOA VARCHAR(4),
	CONSTRAINT PK_GIAOVIEN PRIMARY KEY (MAGV)
)
GO

-- Bảng LOP
CREATE TABLE LOP
(
	MALOP CHAR(3),
	TENLOP VARCHAR(40),
	TRGLOP CHAR(5), -- Mã học viên
	SISO TINYINT,
	MAGVCN CHAR(4), -- Mã giáo viên
	CONSTRAINT PK_LOP PRIMARY KEY (MALOP)
)
GO

-- Bảng HOCVIEN
CREATE TABLE HOCVIEN
(
	MAHV CHAR(5),
	HO VARCHAR(40),
	TEN VARCHAR(10),
	NGSINH SMALLDATETIME,
	GIOITINH VARCHAR(3),
	NOISINH VARCHAR(40),
	MALOP CHAR(3),
	CONSTRAINT PK_HOCVIEN PRIMARY KEY (MAHV)
)
GO

-- Bảng GIANGDAY
CREATE TABLE GIANGDAY
(
	MALOP CHAR(3), -- Thuộc tính khoa
	MAMH VARCHAR(10), -- Thuộc tính khoa
	MAGV CHAR(4),
	HOCKY TINYINT,
	NAM SMALLINT,
	TUNGAY SMALLDATETIME,
	DENNGAY SMALLDATETIME,
	CONSTRAINT PK_GIANGDAY PRIMARY KEY (MALOP, MAMH)
)
GO

-- Quan hệ: KETQUATHI
CREATE TABLE KETQUATHI
(
	MAHV CHAR(5), -- Thuộc tính khoa
	MAMH VARCHAR(10), -- Thuộc tính khoa
	LANTHI TINYINT, -- Thuộc tính khoa
	NGTHI SMALLDATETIME,
	DIEM NUMERIC(4,2),
	KQUA VARCHAR(10),
	CONSTRAINT PK_KETQUATHI PRIMARY KEY (MAHV, MAMH, LANTHI)
)
GO

-- Khóa ngoại
ALTER TABLE LOP ADD CONSTRAINT FK_TRGLOP FOREIGN KEY (TRGLOP) REFERENCES HOCVIEN(MAHV)
ALTER TABLE LOP ADD CONSTRAINT FK_MAGVCN FOREIGN KEY (MAGVCN) REFERENCES GIAOVIEN(MAGV)
ALTER TABLE HOCVIEN ADD CONSTRAINT FK_MALOP FOREIGN KEY (MALOP) REFERENCES LOP(MALOP)
ALTER TABLE GIAOVIEN ADD CONSTRAINT FK_MAKHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
ALTER TABLE GIANGDAY ADD CONSTRAINT FK_MAMH FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH)
ALTER TABLE MONHOC ADD CONSTRAINT FK_MAKHOA2 FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
ALTER TABLE KHOA ADD CONSTRAINT FK_TRGKHOA FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN(MAGV)
ALTER TABLE DIEUKIEN ADD CONSTRAINT FK_MAMH2 FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH)
ALTER TABLE DIEUKIEN ADD CONSTRAINT FK_MAMH_TRUOC FOREIGN KEY (MAMH_TRUOC) REFERENCES MONHOC(MAMH)
ALTER TABLE KETQUATHI ADD CONSTRAINT FK_MAHV FOREIGN KEY (MAHV) REFERENCES HOCVIEN(MAHV)
GO

-- Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN
ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(100), DIEMTB NUMERIC(4,2), XEPLOAI VARCHAR(10)
GO

-- Câu 2: Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp
ALTER TABLE HOCVIEN ADD CONSTRAINT CK_MAHV CHECK (LEN(MAHV) = 5 AND LEFT(MAHV, 3) = MALOP AND ISNUMERIC(RIGHT(MAHV, 2)) = 1)
GO

-- Câu 3:Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”
ALTER TABLE HOCVIEN ADD CONSTRAINT CK_GIOITINHHV CHECK (GIOITINH IN ('Nam', 'Nu'))
ALTER TABLE GIAOVIEN ADD CONSTRAINT CK_GIOITINHGV CHECK (GIOITINH IN ('Nam', 'Nu'))
GO

-- Câu 4: Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẻ (VD: 6.22)
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_DIEM CHECK 
(
	DIEM BETWEEN 0 AND 10
	AND RIGHT (CAST(DIEM AS VARCHAR), 3) LIKE '.__' -- Tham khảo trên mạng
)
GO

-- Câu 5: Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_KETQUA CHECK
(
	(DIEM < 5 AND KQUA = 'Khong dat') OR (DIEM BETWEEN 5 AND 10 AND KQUA = 'Dat')
)
GO

-- Câu 6: Học viên thi một môn tối đa 3 lần
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_LANTHI CHECK (LANTHI <= 3) 
GO

-- Câu 7: Học kỳ chỉ có giá trị từ 1 đến 3
ALTER TABLE GIANGDAY ADD CONSTRAINT CK_HOCKY CHECK (HOCKY IN ('1', '2', '3'))
GO

-- Câu 8: Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”
ALTER TABLE GIAOVIEN ADD CONSTRAINT CK_HOCVI CHECK (HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'))
GO


-- Câu 9: Lớp trưởng của một lớp phải là học viên của lớp đó. 
CREATE TRIGGER TRGLOP_1 ON LOP FOR INSERT, UPDATE
AS
BEGIN
	IF (SELECT COUNT(*) FROM INSERTED, HOCVIEN
		WHERE INSERTED.TRGLOP = HOCVIEN.MAHV AND HOCVIEN.MALOP != INSERTED.MALOP) > 0
	BEGIN
		ROLLBACK TRAN
		PRINT 'Lớp trưởng của một lớp phải là học viên của lớp đó'
	END
	ELSE
		PRINT 'Cập nhật thành công'
END
GO

CREATE TRIGGER TRGHOCVIEN_1 ON HOCVIEN FOR UPDATE
AS
BEGIN
	IF (SELECT COUNT(*) FROM INSERTED, LOP
		WHERE INSERTED.MAHV = LOP.TRGLOP AND INSERTED.MALOP != LOP.MALOP) > 0
	BEGIN
		ROLLBACK TRAN
		PRINT 'Lớp trưởng của một lớp phải là học viên của lớp đó'
	END
	ELSE
		PRINT 'Cập nhật thành công'
END
GO

-- CÂU 10: Trưởng khoa phải là giáo viên thuộc khoa và có học vị "TS" hoặc "PTS"
CREATE TRIGGER TRGKHOA_1 ON KHOA FOR UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM Inserted, GIAOVIEN
WHERE Inserted.TRGKHOA = GIAOVIEN.MAGV AND (GIAOVIEN.HOCVI NOT IN ('TS', 'PTS')
OR GIAOVIEN.MAKHOA != Inserted.MAKHOA)) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

CREATE TRIGGER TRGGIAOVIEN_1 ON GIAOVIEN FOR UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM Inserted, KHOA
WHERE Inserted.MAGV = KHOA.TRGKHOA AND (Inserted.HOCVI NOT IN ('TS', 'PTS')
OR Inserted.MAKHOA != KHOA.MAKHOA)) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

-- CÂU 11: Học viên ít nhất là 18 tuổi
ALTER TABLE HOCVIEN ADD CONSTRAINT CK_TUOI CHECK (YEAR(GETDATE()) - YEAR(NGSINH) >= 18)
GO

-- CÂU 12: Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY)
ALTER TABLE GIANGDAY ADD CONSTRAINT CK_GIANGDAY CHECK (TUNGAY < DENNGAY)
GO

-- CÂU 13: Giáo viên khi vào làm ít nhất là 22 tuổi
ALTER TABLE GIAOVIEN ADD CONSTRAINT CK_NGVL CHECK (YEAR(NGVL) - YEAR(NGSINH) >= 22)
GO

-- CÂU 14: Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3
ALTER TABLE MONHOC ADD CONSTRAINT CK_TINCHI CHECK (ABS(TCLT - TCTH) <= 3)
GO

-- CÂU 15: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này
CREATE TRIGGER TRGHOCVIEN_2 ON HOCVIEN FOR INSERT, UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM Inserted, KETQUATHI, GIANGDAY GD1
WHERE Inserted.MAHV = KETQUATHI.MAHV
AND (KETQUATHI.MAMH NOT IN (
SELECT MAMH FROM GIANGDAY GD2
WHERE Inserted.MALOP = GD2.MALOP)
OR (Inserted.MALOP = GD1.MALOP AND KETQUATHI.MAMH = GD1.MAMH AND KETQUATHI.NGTHI > GD1.DENNGAY))
) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

-- CÂU 16: Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn
CREATE TRIGGER TRGGIANGDAY_1 ON GIANGDAY FOR INSERT, UPDATE
AS
BEGIN
IF (SELECT TOP 1 COUNT(MAMH)
FROM GIANGDAY
GROUP BY HOCKY, NAM, MALOP) > 3
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

-- Câu 17: Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó
CREATE TRIGGER TRGHOCVIEN_3 ON HOCVIEN FOR INSERT, UPDATE, DELETE
AS
BEGIN
UPDATE LOP SET SISO = (
SELECT COUNT(*) FROM HOCVIEN
WHERE HOCVIEN.MALOP = LOP.MALOP
)
END
GO

-- Câu 18: Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”)
CREATE TRIGGER TRGDIEUKIEN_1 ON DIEUKIEN FOR INSERT, UPDATE
AS
BEGIN
IF (
SELECT COUNT(*) FROM DIEUKIEN DK1, DIEUKIEN DK2
WHERE DK1.MAMH = DK1.MAMH_TRUOC
OR (DK1.MAMH = DK2.MAMH_TRUOC AND DK1.MAMH_TRUOC = DK2.MAMH)
) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

-- Câu 19: Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau
CREATE TRIGGER TRGGIAOVIEN_3 ON GIAOVIEN FOR INSERT, UPDATE
AS
BEGIN
IF (
SELECT COUNT(*) FROM GIAOVIEN GV1, GIAOVIEN GV2
WHERE GV1.HOCVI = GV2.HOCVI
AND GV1.HOCHAM = GV2.HOCHAM
AND GV1.HESO = GV2.HESO
AND GV1.MUCLUONG != GV2.MUCLUONG
) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

-- Câu 20: Học viên chỉ được thi lại (lần thi > 1) khi điểm của lần thi trước đó dưới 5
CREATE TRIGGER TRGKETQUATHI_1 ON KETQUATHI FOR INSERT, UPDATE
AS
BEGIN
IF (
SELECT COUNT(*) FROM KETQUATHI KQ1, KETQUATHI KQ2
WHERE KQ1.MAHV = KQ2.MAHV
AND KQ1.MAMH = KQ2.MAMH
AND KQ1.LANTHI + 1 = KQ2.LANTHI
AND KQ1.LANTHI > 5
) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO

-- Câu 21: Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
CREATE TRIGGER TRGKETQUATHI_2 ON KETQUATHI FOR INSERT, UPDATE
AS
BEGIN
IF (
SELECT COUNT(*) FROM KETQUATHI KQ1, KETQUATHI KQ2
WHERE KQ1.MAHV = KQ2.MAHV
AND KQ1.MAMH = KQ2.MAMH
AND KQ1.LANTHI < KQ2.LANTHI
AND KQ1.NGTHI >= KQ2.NGTHI
) > 0
BEGIN
ROLLBACK TRAN
PRINT 'Cập nhật không thành công'
END
ELSE
PRINT 'Cập nhật thành công'
END
GO
-- CÂU 22: Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong
CREATE TRIGGER TRGHOCVIEN_4 ON HOCVIEN FOR INSERT, UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM INSERTED, KETQUATHI, GIANGDAY GD1
WHERE INSERTED.MAHV = KETQUATHI.MAHV
AND (KETQUATHI.MAMH NOT IN (
SELECT MAMH FROM GIANGDAY GD2
WHERE INSERTED.MALOP = GD2.MALOP)
OR (INSERTED.MALOP = GD1.MALOP AND KETQUATHI.MAMH = GD1.MAMH AND KETQUATHI.NGTHI > GD1.DENNGAY))
) > 0
BEGIN
ROLLBACK TRAN
PRINT 'CẬP NHẬT KHÔNG THÀNH CÔNG'
END
ELSE
PRINT 'CẬP NHẬT THÀNH CÔNG'
END
GO

-- CÂU 23: Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau)
CREATE TRIGGER TRGGIANGDAY_2 ON GIANGDAY FOR INSERT, UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM GIANGDAY GD1, GIANGDAY GD2, DIEUKIEN
WHERE GD1.MALOP = GD2.MALOP
AND GD1.MAMH = DIEUKIEN.MAMH
AND GD2.MAMH = DIEUKIEN.MAMH_TRUOC
AND GD1.TUNGAY < GD2.DENNGAY) > 0
BEGIN
ROLLBACK TRAN
PRINT 'CẬP NHẬT KHÔNG THÀNH CÔNG'
END
ELSE
PRINT 'CẬP NHẬT THÀNH CÔNG'
END
GO

-- CÂU 24: Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách
CREATE TRIGGER TRGGIANGDAY_3 ON GIANGDAY FOR INSERT, UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM GIANGDAY, GIAOVIEN, MONHOC
WHERE GIANGDAY.MAGV = GIAOVIEN.MAGV
AND GIANGDAY.MAMH = MONHOC.MAMH
AND GIAOVIEN.MAKHOA != MONHOC.MAKHOA) > 0
BEGIN
ROLLBACK TRAN
PRINT 'CẬP NHẬT KHÔNG THÀNH CÔNG'
END
ELSE
PRINT 'CẬP NHẬT THÀNH CÔNG'
END

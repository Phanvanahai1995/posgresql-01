CREATE TABLE phong(
	MaPhong VARCHAR(50) PRIMARY KEY NOT NULL,
	LoaiPhong VARCHAR(50) NOT NULL,
	SoKhacToiDa INTEGER NOT NULL,
	GiaPhong INTEGER NOT NULL,
	MoTa VARCHAR(250)
);

CREATE TABLE khach_hang(
	MaKH VARCHAR(50) PRIMARY KEY NOT NULL,
	TenKH VARCHAR(50) NOT NULL,
	DiaChi VARCHAR(100) NOT NULL,
	SoDT VARCHAR(25) NOT NULL
);

CREATE TABLE dich_vu_di_kem(
	MaDV VARCHAR(50) NOT NULL,
	TenDV VARCHAR(50) NOT NULL,
	DonViTinh VARCHAR(50) NOT NULL,
	DonGia INTEGER NOT NULL
);

CREATE TYPE status AS ENUM ('Da dat','Da huy');
CREATE TABLE dat_phong(
	MaDatPhong VARCHAR(50) PRIMARY KEY NOT NULL,
	MaPhong VARCHAR(50) REFERENCES phong(MaPhong) NOT NULL,
	MaKH VARCHAR(50) REFERENCES khach_hang(MaKH) NOT NULL,
	NgayDat DATE NOT NULL,
	GioBatDau TIME NOT NULL,
	GioKetThuc TIME NOT NULL,
	TienDatCoc INTEGER NOT NULL,
	GhiChu VARCHAR(250),
	TrangThaiDat status 
);

CREATE TABLE chi_tiet_su_dung_dich_vu(
	MaDatPhong VARCHAR(50) REFERENCES dat_phong(MaDatPhong) NOT NULL,
	MaDV VARCHAR(50) REFERENCES dich_vu_di_kem(MaDV) NOT NULL,
	SoLuong INTEGER NOT NULL
);

-- Câu 1
SELECT dat_phong.madatphong, 
phong.loaiphong,
phong.giaphong,
khach_hang.tenkh,
dat_phong.ngaydat,
(phong.giaphong*ROUND((EXTRACT(MINUTE FROM (gioketthuc - giobatdau))/60 + EXTRACT(HOUR FROM (gioketthuc - giobatdau))))) AS tongtienhat,
(dich_vu.soluong*dich_vu.dongia) AS tongtiensudungdichvu,
(phong.giaphong*ROUND((EXTRACT(MINUTE FROM (gioketthuc - giobatdau))/60 + EXTRACT(HOUR FROM (gioketthuc - giobatdau)))) + dich_vu.soluong*dich_vu.dongia  - dat_phong.tiendatcoc) AS tongtienthanhtoan
FROM dat_phong
INNER JOIN phong ON dat_phong.maphong = phong.maphong
INNER JOIN khach_hang ON khach_hang.makh = dat_phong.makh
LEFT JOIN (SELECT * FROM chi_tiet_su_dung_dich_vu 
INNER JOIN dich_vu_di_kem ON dich_vu_di_kem.madv = chi_tiet_su_dung_dich_vu.madv) AS dich_vu ON dat_phong.madatphong = dich_vu.madatphong;

-- Câu 2
SELECT khach_hang.*
FROM dat_phong
INNER JOIN phong ON dat_phong.maphong = phong.maphong
INNER JOIN khach_hang ON khach_hang.makh = dat_phong.makh
WHERE khach_hang.diachi ILIKE 'Hoa xuan';

-- Câu 3
SELECT phong.maphong,phong.loaiphong, phong.sokhactoida,phong.giaphong, COUNT(*)
FROM dat_phong
INNER JOIN phong ON dat_phong.maphong = phong.maphong
INNER JOIN khach_hang ON khach_hang.makh = dat_phong.makh
WHERE dat_phong.trangthaidat ILIKE 'Da dat'
GROUP BY phong.maphong,phong.loaiphong, phong.sokhactoida,phong.giaphong
HAVING COUNT(*) >= 2;

-- Câu 4
SELECT (regexp_split_to_array(tenkh, E'\\s+'))[array_length(regexp_split_to_array(tenkh, E'\\s+'),1)] as ten_khach_hang
FROM khach_hang
WHERE (regexp_split_to_array(tenkh, E'\\s+'))[array_length(regexp_split_to_array(tenkh, E'\\s+'),1)] ILIKE 'n%' 
OR (regexp_split_to_array(tenkh, E'\\s+'))[array_length(regexp_split_to_array(tenkh, E'\\s+'),1)] ILIKE 'h%' 
OR (regexp_split_to_array(tenkh, E'\\s+'))[array_length(regexp_split_to_array(tenkh, E'\\s+'),1)] ILIKE'm%'
AND LENGTH((regexp_split_to_array(tenkh, E'\\s+'))[array_length(regexp_split_to_array(tenkh, E'\\s+'),1)]) <=20
GROUP BY ten_khach_hang;

-- Câu 5
SELECT tenkh
FROM khach_hang
GROUP BY tenkh;

-- Câu 6
SELECT * FROM dich_vu_di_kem
WHERE (donvitinh ILIKE 'lon'
AND dongia > 10000 ) 
OR (donvitinh ILIKE 'cai' AND dongia < 5000)
;

-- Câu 7
SELECT dat_phong.madatphong, 
phong.maphong,
phong.loaiphong,
phong.sokhactoida,
phong.giaphong,
khach_hang.tenkh,
dat_phong.makh,
khach_hang.sodt,
dat_phong.ngaydat,
dat_phong.giobatdau,
dat_phong.gioketthuc,
dich_vu.madv,
dich_vu.soluong,
dich_vu.dongia
FROM dat_phong
INNER JOIN phong ON dat_phong.maphong = phong.maphong
INNER JOIN khach_hang ON khach_hang.makh = dat_phong.makh
INNER JOIN (SELECT dich_vu_di_kem.*,chi_tiet_su_dung_dich_vu.madatphong,chi_tiet_su_dung_dich_vu.soluong FROM chi_tiet_su_dung_dich_vu 
INNER JOIN dich_vu_di_kem ON dich_vu_di_kem.madv = chi_tiet_su_dung_dich_vu.madv) AS dich_vu ON dat_phong.madatphong = dich_vu.madatphong
WHERE EXTRACT(YEAR FROM dat_phong.ngaydat) IN (2016,2017)
AND phong.giaphong > 50000

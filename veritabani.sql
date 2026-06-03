-- phpMyAdmin SQL Dump
-- version 5.2.1
-- Sunucu sürümü: 10.4.28-MariaDB

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `farmakoloji_db` DEFAULT CHARACTER SET utf8 COLLATE utf8_turkish_ci;
USE `farmakoloji_db`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_kapsamli_ilac_ekle`$$
CREATE PROCEDURE `sp_kapsamli_ilac_ekle` (IN `p_jenerik` VARCHAR(100), IN `p_kimyasal` VARCHAR(200), IN `p_agirlik` FLOAT, IN `p_saat` INT, IN `p_sinif_id` INT, IN `p_onay_yili` INT, IN `p_hedef_id` INT, IN `p_etki_tipi` VARCHAR(50), IN `p_enzim_id` INT, IN `p_metabolik_rol` VARCHAR(50))  NO SQL
BEGIN
    DECLARE yeni_madde_id INT;
    IF p_agirlik < 0 THEN SET p_agirlik = 0; END IF;
    INSERT INTO etken_madde (jenerik_isim, kimyasal_isim, molekul_agirligi, yari_omur_saat) 
    VALUES (p_jenerik, p_kimyasal, p_agirlik, p_saat);
    SET yeni_madde_id = LAST_INSERT_ID();
    INSERT INTO madde_sinif_iliski (madde_id, sinif_id, onay_yili) VALUES (yeni_madde_id, p_sinif_id, p_onay_yili);
    INSERT INTO baglanma_etkisi (madde_id, hedef_id, etki_tipi) VALUES (yeni_madde_id, p_hedef_id, p_etki_tipi);
    INSERT INTO metabolik_profil (madde_id, enzim_id, etkilesim_rolu) VALUES (yeni_madde_id, p_enzim_id, p_metabolik_rol);
END$$
DELIMITER ;

-- TABLOLARIN OLUŞTURULMASI
DROP TABLE IF EXISTS `ilac_etkilesimi`, `madde_yan_etki_profil`, `metabolik_profil`, `baglanma_etkisi`, `madde_sinif_iliski`, `yan_etki`, `karaciger_enzimi`, `biyolojik_hedef`, `ilac_sinifi`, `etken_madde`;

CREATE TABLE `etken_madde` (
  `madde_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `jenerik_isim` varchar(100) COLLATE utf8_turkish_ci NOT NULL UNIQUE,
  `kimyasal_isim` varchar(200) COLLATE utf8_turkish_ci NOT NULL,
  `molekul_agirligi` float DEFAULT 0,
  `yari_omur_saat` int(11) NOT NULL,
  `eklenme_tarihi` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `ilac_sinifi` (
  `sinif_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `sinif_adi` varchar(100) COLLATE utf8_turkish_ci NOT NULL UNIQUE,
  `atc_kodu` varchar(20) COLLATE utf8_turkish_ci NOT NULL,
  `genel_aciklama` text COLLATE utf8_turkish_ci DEFAULT NULL,
  `klinik_kullanim` varchar(200) COLLATE utf8_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `biyolojik_hedef` (
  `hedef_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `hedef_adi` varchar(100) COLLATE utf8_turkish_ci NOT NULL,
  `hedef_tipi` varchar(50) COLLATE utf8_turkish_ci NOT NULL,
  `endojen_ligand` varchar(100) COLLATE utf8_turkish_ci DEFAULT NULL,
  `organ_sistemi` varchar(100) COLLATE utf8_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `karaciger_enzimi` (
  `enzim_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `enzim_adi` varchar(50) COLLATE utf8_turkish_ci NOT NULL UNIQUE,
  `gen_lokusu` varchar(50) COLLATE utf8_turkish_ci DEFAULT NULL,
  `bulunma_yuzdesi` float DEFAULT NULL,
  `reaksiyon_tipi` varchar(50) COLLATE utf8_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `yan_etki` (
  `yan_etki_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `etki_adi` varchar(100) COLLATE utf8_turkish_ci NOT NULL,
  `meddra_kodu` varchar(20) COLLATE utf8_turkish_ci DEFAULT NULL UNIQUE,
  `organ_sistemi` varchar(100) COLLATE utf8_turkish_ci NOT NULL,
  `siddet_derecesi` varchar(20) COLLATE utf8_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `madde_sinif_iliski` (
  `iliski_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `madde_id` int(11) NOT NULL,
  `sinif_id` int(11) NOT NULL,
  `birincil_sinif_mi` tinyint(1) DEFAULT 1,
  `onay_yili` int(11) DEFAULT NULL,
  FOREIGN KEY (`madde_id`) REFERENCES `etken_madde` (`madde_id`) ON DELETE CASCADE,
  FOREIGN KEY (`sinif_id`) REFERENCES `ilac_sinifi` (`sinif_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `baglanma_etkisi` (
  `etki_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `madde_id` int(11) NOT NULL,
  `hedef_id` int(11) NOT NULL,
  `etki_tipi` varchar(50) COLLATE utf8_turkish_ci NOT NULL,
  `baglanma_afinitesi` varchar(50) COLLATE utf8_turkish_ci DEFAULT NULL,
  FOREIGN KEY (`hedef_id`) REFERENCES `biyolojik_hedef` (`hedef_id`) ON DELETE CASCADE,
  FOREIGN KEY (`madde_id`) REFERENCES `etken_madde` (`madde_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `metabolik_profil` (
  `profil_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `madde_id` int(11) NOT NULL,
  `enzim_id` int(11) NOT NULL,
  `etkilesim_rolu` varchar(50) COLLATE utf8_turkish_ci NOT NULL,
  `klerens_hizi` varchar(50) COLLATE utf8_turkish_ci DEFAULT NULL,
  FOREIGN KEY (`enzim_id`) REFERENCES `karaciger_enzimi` (`enzim_id`) ON DELETE CASCADE,
  FOREIGN KEY (`madde_id`) REFERENCES `etken_madde` (`madde_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `madde_yan_etki_profil` (
  `profil_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `madde_id` int(11) NOT NULL,
  `yan_etki_id` int(11) NOT NULL,
  `gorulme_frekans` varchar(50) COLLATE utf8_turkish_ci DEFAULT NULL,
  `kara_kutu_uyarisi` tinyint(1) DEFAULT 0,
  FOREIGN KEY (`madde_id`) REFERENCES `etken_madde` (`madde_id`) ON DELETE CASCADE,
  FOREIGN KEY (`yan_etki_id`) REFERENCES `yan_etki` (`yan_etki_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

CREATE TABLE `ilac_etkilesimi` (
  `etkilesim_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `madde1_id` int(11) NOT NULL,
  `madde2_id` int(11) NOT NULL,
  `siddet_seviyesi` varchar(20) COLLATE utf8_turkish_ci NOT NULL,
  `yonetim_tavsiyesi` text COLLATE utf8_turkish_ci DEFAULT NULL,
  FOREIGN KEY (`madde1_id`) REFERENCES `etken_madde` (`madde_id`) ON DELETE CASCADE,
  FOREIGN KEY (`madde2_id`) REFERENCES `etken_madde` (`madde_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

-- 20'ŞER ADET ÖRNEK VERİ GİRİŞİ (TOPLAM 200 SATIR)

INSERT INTO `etken_madde` (`madde_id`, `jenerik_isim`, `kimyasal_isim`, `molekul_agirligi`, `yari_omur_saat`, `eklenme_tarihi`) VALUES
(1, 'Metoprolol', 'Propan-2-ol türevi', 267.36, 4, '2023-01-15 07:00:00'),
(2, 'Sertralin', 'Tetrahidronaftalen', 306.23, 26, '2023-02-12 11:30:00'),
(3, 'İbuprofen', 'Propanoik asit', 206.29, 2, '2023-03-05 06:15:00'),
(4, 'Ramipril', 'Karboksilik asit', 416.51, 15, '2023-04-20 09:10:00'),
(5, 'Amlodipin', 'Dihidropiridin', 408.88, 40, '2023-05-18 14:25:00'),
(6, 'Atorvastatin', 'Pirol-heptanoik asit', 558.64, 14, '2023-06-22 08:45:00'),
(7, 'Pantoprazol', 'Benzimidazol', 383.37, 2, '2023-07-30 10:05:00'),
(8, 'Setirizin', 'Piperazin', 388.89, 8, '2023-08-14 16:50:00'),
(9, 'Rivaroksaban', 'Oksazolidinon', 435.88, 9, '2023-09-01 12:15:00'),
(10, 'Parasetamol', 'Para-asetilaminofenol', 151.16, 3, '2023-10-10 11:20:00'),
(11, 'Amoksisilin', 'Beta-laktam', 365.40, 1, '2023-11-05 09:30:00'),
(12, 'Azitromisin', 'Makrolid halkası', 749.00, 68, '2023-12-12 14:00:00'),
(13, 'Asiklovir', 'Guanin analoğu', 225.20, 3, '2024-01-20 15:45:00'),
(14, 'Flukonazol', 'Triazol', 306.27, 30, '2024-02-15 08:10:00'),
(15, 'Deksametazon', 'Kortikosteroid', 392.46, 36, '2024-03-10 10:20:00'),
(16, 'Furosemid', 'Sülfonamid', 330.74, 2, '2024-04-18 11:00:00'),
(17, 'Metformin', 'Biguanid', 129.16, 6, '2024-05-22 09:15:00'),
(18, 'Karbamazepin', 'Karboksamid', 236.27, 15, '2024-06-30 13:40:00'),
(19, 'Ketiapin', 'Dibenzotiyazepin', 383.51, 7, '2024-07-25 10:55:00'),
(20, 'Salbutamol', 'Feniletanolamin', 239.31, 4, '2024-08-10 16:30:00');

INSERT INTO `ilac_sinifi` (`sinif_id`, `sinif_adi`, `atc_kodu`, `genel_aciklama`, `klinik_kullanim`) VALUES
(1, 'Beta Bloker', 'C07AB', 'Kalp hızını düşürür', 'Hipertansiyon'),
(2, 'SSRI', 'N06AB', 'Serotonin gerialım inhibitörü', 'Depresyon'),
(3, 'NSAID', 'M01AE', 'Ağrı ve iltihap kesici', 'İnflamasyon'),
(4, 'ACE İnhibitörü', 'C09AA', 'Damar genişletici', 'Hipertansiyon'),
(5, 'Kalsiyum Kanal Blokörü', 'C08CA', 'Kasılmayı engeller', 'Aritmi ve Tansiyon'),
(6, 'Statin', 'C10AA', 'Kolesterol düşürücü', 'Hiperlipidemi'),
(7, 'PPI (Mide Koruyucu)', 'A02BC', 'Asit salgısını azaltır', 'Reflü, Ülser'),
(8, 'Antihistaminik', 'R06AE', 'Alerji semptomlarını baskılar', 'Alerji'),
(9, 'Antikoagülan', 'B01AF', 'Kan sulandırıcı', 'Tromboz'),
(10, 'Analjezik', 'N02BE', 'Basit ağrı kesici', 'Ateş ve Ağrı'),
(11, 'Penisilin Antibiyotik', 'J01CA', 'Hücre duvarı sentezini bozar', 'Bakteriyel Enfeksiyon'),
(12, 'Makrolid Antibiyotik', 'J01FA', 'Ribozoma bağlanır', 'Solunum Yolu Enfeksiyonu'),
(13, 'Antiviral', 'J05AB', 'Viral replikasyonu durdurur', 'Herpes, Zona'),
(14, 'Antifungal', 'J02AC', 'Mantar hücresini yok eder', 'Mantar Enfeksiyonu'),
(15, 'Kortikosteroid', 'H02AB', 'Güçlü anti-inflamatuar', 'Ağır İltihap, Astım'),
(16, 'Diüretik (İdrar Söktürücü)', 'C03CA', 'Sıvı atılımını artırır', 'Ödem, Kalp Yetmezliği'),
(17, 'Antidiyabetik', 'A10BA', 'İnsülin duyarlılığını artırır', 'Tip 2 Diyabet'),
(18, 'Antikonvülzan', 'N03AF', 'Sinir sinyallerini yavaşlatır', 'Epilepsi'),
(19, 'Antipsikotik', 'N05AH', 'Dopamin antagonisti', 'Şizofreni, Bipolar'),
(20, 'Bronkodilatör', 'R03AC', 'Hava yollarını genişletir', 'Astım, KOAH');

INSERT INTO `biyolojik_hedef` (`hedef_id`, `hedef_adi`, `hedef_tipi`, `endojen_ligand`, `organ_sistemi`) VALUES
(1, 'Beta-1 Adrenerjik', 'GPCR', 'Adrenalin', 'Kardiyovasküler'),
(2, 'SERT', 'Taşıyıcı Protein', 'Serotonin', 'Merkezi Sinir Sistemi'),
(3, 'COX-1 / COX-2', 'Enzim', 'Araşidonik Asit', 'Sistemik'),
(4, 'ACE', 'Enzim', 'Anjiyotensin I', 'Kardiyovasküler'),
(5, 'L-Tipi Kalsiyum Kanalı', 'İyon Kanalı', 'Kalsiyum', 'Kardiyovasküler'),
(6, 'HMG-CoA Redüktaz', 'Enzim', 'HMG-CoA', 'Karaciğer'),
(7, 'H+/K+ ATPaz Pompası', 'İyon Pompası', 'ATP', 'Gastrointestinal'),
(8, 'H1 Reseptörü', 'GPCR', 'Histamin', 'Sistemik'),
(9, 'Faktör Xa', 'Pıhtılaşma Faktörü', 'Protrombin', 'Kan'),
(10, 'COX-3', 'Enzim', 'Araşidonik Asit', 'Merkezi Sinir Sistemi'),
(11, 'PBP (Penisilin Bağlayan)', 'Enzim', 'Peptidoglikan', 'Bakteri Hücresi'),
(12, '50S Ribozomal Alt Birim', 'Ribozom', 'RNA', 'Bakteri Hücresi'),
(13, 'Viral DNA Polimeraz', 'Enzim', 'Nükleotid', 'Virüs Hücresi'),
(14, '14-Alfa Demetilaz', 'Enzim', 'Lanosterol', 'Mantar Hücresi'),
(15, 'Glukokortikoid Reseptörü', 'Nükleer Reseptör', 'Kortizol', 'Bağışıklık Sistemi'),
(16, 'Na-K-2Cl Ko-transporter', 'Taşıyıcı Protein', 'Sodyum', 'Böbrekler'),
(17, 'AMPK', 'Kinaz Enzimi', 'AMP', 'Karaciğer, Kas'),
(18, 'Voltaj Kapılı Sodyum Kanalı', 'İyon Kanalı', 'Sodyum', 'Merkezi Sinir Sistemi'),
(19, 'D2 / 5-HT2A Reseptörleri', 'GPCR', 'Dopamin', 'Merkezi Sinir Sistemi'),
(20, 'Beta-2 Adrenerjik', 'GPCR', 'Adrenalin', 'Solunum Sistemi');

INSERT INTO `karaciger_enzimi` (`enzim_id`, `enzim_adi`, `gen_lokusu`, `bulunma_yuzdesi`, `reaksiyon_tipi`) VALUES
(1, 'CYP3A4', '7q22.1', 30.5, 'Oksidasyon'),
(2, 'CYP2D6', '22q13.2', 2.0, 'Hidroksilasyon'),
(3, 'CYP2C9', '10q23.33', 15.0, 'Oksidasyon'),
(4, 'CYP2C19', '10q23.33', 5.0, 'Oksidasyon'),
(5, 'CYP1A2', '15q24.1', 13.0, 'N-demetilasyon'),
(6, 'CYP2E1', '10q26.3', 7.0, 'Oksidasyon'),
(7, 'CYP2A6', '19q13.2', 4.0, 'C-oksidasyon'),
(8, 'CYP2B6', '19q13.2', 3.0, 'Oksidasyon'),
(9, 'CYP2C8', '10q23.33', 6.0, 'Hidroksilasyon'),
(10, 'CYP2J2', '1p31.3', 1.5, 'Oksidasyon'),
(11, 'CYP4F2', '19p13.12', 2.5, 'Oksidasyon'),
(12, 'UGT1A1', '2q37.1', 10.0, 'Glukuronidasyon'),
(13, 'UGT1A4', '2q37.1', 5.0, 'Glukuronidasyon'),
(14, 'UGT2B7', '4q13.2', 8.0, 'Glukuronidasyon'),
(15, 'SULT1A1', '16p11.2', 12.0, 'Sülfatasyon'),
(16, 'NAT2', '8p22', 10.0, 'Asetilasyon'),
(17, 'GST', '11q13', 15.0, 'Glutatyon Konjugasyonu'),
(18, 'FMO3', '1q24.3', 5.0, 'N-oksidasyon'),
(19, 'MAO-A', 'Xp11.3', 8.0, 'Amin Oksidasyonu'),
(20, 'COMT', '22q11.21', 10.0, 'Metilasyon');

INSERT INTO `yan_etki` (`yan_etki_id`, `etki_adi`, `meddra_kodu`, `organ_sistemi`, `siddet_derecesi`) VALUES
(1, 'Bradikardi (Düşük Nabız)', '10006093', 'Kardiyovasküler', 'Orta'),
(2, 'İnsomnia (Uykusuzluk)', '10022437', 'Merkezi Sinir Sistemi', 'Hafif'),
(3, 'Mide Kanaması', '10017955', 'Gastrointestinal', 'Ciddi'),
(4, 'Kuru Öksürük', '10011224', 'Solunum Sistemi', 'Hafif'),
(5, 'Periferik Ödem', '10034474', 'Kardiyovasküler', 'Orta'),
(6, 'Miyopati (Kas Ağrısı)', '10028606', 'Kas İskelet Sistemi', 'Ciddi'),
(7, 'B12 Vitamini Eksikliği', '10047462', 'Sistemik', 'Orta'),
(8, 'Uyku Hali', '10041349', 'Merkezi Sinir Sistemi', 'Hafif'),
(9, 'Kanamaya Eğilim', '10019805', 'Kan', 'Ciddi'),
(10, 'Hepatotoksisite', '10019851', 'Karaciğer', 'Çok Ciddi'),
(11, 'Anafilaksi', '10002198', 'Bağışıklık Sistemi', 'Çok Ciddi'),
(12, 'İshal', '10012735', 'Gastrointestinal', 'Hafif'),
(13, 'Böbrek Yetmezliği', '10038435', 'Renal', 'Ciddi'),
(14, 'QT Uzaması', '10014387', 'Kardiyovasküler', 'Ciddi'),
(15, 'Osteoporoz', '10031282', 'Kas İskelet Sistemi', 'Orta'),
(16, 'Hipokalemi', '10020950', 'Metabolizma', 'Ciddi'),
(17, 'Laktik Asidoz', '10023608', 'Metabolizma', 'Çok Ciddi'),
(18, 'Baş Dönmesi', '10013573', 'Merkezi Sinir Sistemi', 'Hafif'),
(19, 'Kilo Alımı', '10047896', 'Metabolizma', 'Orta'),
(20, 'Çarpıntı', '10033669', 'Kardiyovasküler', 'Hafif');

INSERT INTO `madde_sinif_iliski` (`madde_id`, `sinif_id`, `birincil_sinif_mi`, `onay_yili`) VALUES
(1, 1, 1, 1978), (2, 2, 1, 1991), (3, 3, 1, 1974), (4, 4, 1, 1991), (5, 5, 1, 1990),
(6, 6, 1, 1996), (7, 7, 1, 1994), (8, 8, 1, 1995), (9, 9, 1, 2011), (10, 10, 1, 1955),
(11, 11, 1, 1972), (12, 12, 1, 1991), (13, 13, 1, 1981), (14, 14, 1, 1990), (15, 15, 1, 1958),
(16, 16, 1, 1966), (17, 17, 1, 1995), (18, 18, 1, 1968), (19, 19, 1, 1997), (20, 20, 1, 1968);

INSERT INTO `baglanma_etkisi` (`madde_id`, `hedef_id`, `etki_tipi`, `baglanma_afinitesi`) VALUES
(1, 1, 'Antagonist', 'Yüksek'), (2, 2, 'İnhibitör', 'Yüksek'), (3, 3, 'İnhibitör', 'Orta'), (4, 4, 'İnhibitör', 'Yüksek'), (5, 5, 'Blokör', 'Yüksek'),
(6, 6, 'İnhibitör', 'Yüksek'), (7, 7, 'İnhibitör', 'Çok Yüksek'), (8, 8, 'Antagonist', 'Yüksek'), (9, 9, 'İnhibitör', 'Yüksek'), (10, 10, 'İnhibitör', 'Zayıf'),
(11, 11, 'İnhibitör', 'Yüksek'), (12, 12, 'İnhibitör', 'Yüksek'), (13, 13, 'İnhibitör', 'Yüksek'), (14, 14, 'İnhibitör', 'Yüksek'), (15, 15, 'Agonist', 'Çok Yüksek'),
(16, 16, 'İnhibitör', 'Yüksek'), (17, 17, 'Aktivatör', 'Orta'), (18, 18, 'Blokör', 'Yüksek'), (19, 19, 'Antagonist', 'Yüksek'), (20, 20, 'Agonist', 'Yüksek');

INSERT INTO `metabolik_profil` (`madde_id`, `enzim_id`, `etkilesim_rolu`, `klerens_hizi`) VALUES
(1, 2, 'Substrat', 'Hızlı'), (2, 1, 'Substrat / İnhibitör', 'Orta'), (3, 3, 'Substrat', 'Hızlı'), (4, 1, 'Substrat', 'Orta'), (5, 1, 'Substrat', 'Yavaş'),
(6, 1, 'Substrat', 'Hızlı'), (7, 4, 'Substrat', 'Hızlı'), (8, 1, 'Substrat', 'Orta'), (9, 1, 'Substrat', 'Hızlı'), (10, 5, 'Substrat', 'Çok Hızlı'),
(11, 1, 'Bilinmiyor', 'Böbrek Atılımı'), (12, 1, 'İnhibitör', 'Çok Yavaş'), (13, 1, 'Bilinmiyor', 'Hızlı'), (14, 3, 'Güçlü İnhibitör', 'Yavaş'), (15, 1, 'İndükleyici', 'Orta'),
(16, 12, 'Substrat', 'Hızlı'), (17, 1, 'Metabolize Olmaz', 'Böbrek Atılımı'), (18, 1, 'Güçlü İndükleyici', 'Hızlı'), (19, 1, 'Substrat', 'Hızlı'), (20, 15, 'Substrat', 'Çok Hızlı');

INSERT INTO `madde_yan_etki_profil` (`madde_id`, `yan_etki_id`, `gorulme_frekans`, `kara_kutu_uyarisi`) VALUES
(1, 1, 'Yaygın', 0), (2, 2, 'Yaygın', 1), (3, 3, 'Seyrek', 1), (4, 4, 'Çok Yaygın', 0), (5, 5, 'Yaygın', 0),
(6, 6, 'Seyrek', 0), (7, 7, 'Seyrek', 0), (8, 8, 'Yaygın', 0), (9, 9, 'Yaygın', 1), (10, 10, 'Çok Seyrek', 1),
(11, 11, 'Seyrek', 0), (12, 12, 'Yaygın', 0), (13, 13, 'Seyrek', 0), (14, 14, 'Seyrek', 0), (15, 15, 'Yaygın (Uzun Kullanım)', 0),
(16, 16, 'Yaygın', 1), (17, 17, 'Çok Seyrek', 1), (18, 18, 'Yaygın', 1), (19, 19, 'Yaygın', 1), (20, 20, 'Yaygın', 0);

INSERT INTO `ilac_etkilesimi` (`madde1_id`, `madde2_id`, `siddet_seviyesi`, `yonetim_tavsiyesi`) VALUES
(1, 5, 'Orta', 'Kan basıncını çok düşürebilir, dikkatli izleyin.'),
(2, 3, 'Ciddi', 'Mide kanaması riski artar, PPI ekleyin.'),
(3, 4, 'Ciddi', 'ACE inhibitörünün etkisini azaltır, böbrek fonksiyonunu bozabilir.'),
(6, 12, 'Çok Ciddi', 'Miyopati ve Rabdomiyoliz riski! Birlikte kullanımdan kaçının.'),
(9, 3, 'Ciddi', 'Kanama riski aşırı artar.'),
(10, 14, 'Orta', 'Karaciğer enzimleri yükselebilir.'),
(18, 6, 'Orta', 'Statinin kan seviyesini düşürür, dozu artırmak gerekebilir.'),
(19, 14, 'Ciddi', 'Ketiapin kan seviyesi artar, toksisite riski.'),
(16, 3, 'Ciddi', 'Furosemidin idrar söktürücü etkisini bozar.'),
(2, 19, 'Ciddi', 'QT uzaması riski, EKG takibi şart.'),
(1, 12, 'Orta', 'Kalp hızında beklenmeyen değişiklikler olabilir.'),
(4, 16, 'Ciddi', 'Hipotansiyon ve böbrek yetmezliği riski.'),
(5, 6, 'Orta', 'Amlodipin statin seviyesini bir miktar artırabilir.'),
(8, 2, 'Hafif', 'Artmış uyku hali (sedasyon).'),
(15, 3, 'Ciddi', 'Ülser ve mide kanaması riskinde büyük artış.'),
(17, 16, 'Orta', 'Laktik asidoz ve böbrek fonksiyonu takibi gerekir.'),
(12, 7, 'Hafif', 'Emilimde ufak değişiklikler olabilir.'),
(18, 2, 'Orta', 'Sertralin etkisini azaltabilir.'),
(9, 2, 'Ciddi', 'Kanama riski SSRI ile artar.'),
(20, 1, 'Ciddi', 'Birbirlerinin etkilerini tamamen zıt yönde iptal ederler (Antagonizma).');

CREATE VIEW `vw_ilac_genel_ozet` AS 
SELECT 
    `e`.`madde_id` AS `madde_id`, 
    upper(`e`.`jenerik_isim`) AS `jenerik_isim_buyuk`, 
    `e`.`kimyasal_isim` AS `kimyasal_isim`, 
    concat(`e`.`yari_omur_saat`,' Saat') AS `omur_metni`, 
    date_format(`e`.`eklenme_tarihi`,'%d/%m/%Y') AS `kayit_tarihi`, 
    to_days(current_timestamp()) - to_days(`e`.`eklenme_tarihi`) AS `sisteme_ekleneli_kac_gun_oldu`, 
    `s`.`sinif_adi` AS `sinif_adi`, 
    `s`.`klinik_kullanim` AS `klinik_kullanim`, 
    `h`.`hedef_adi` AS `hedef_adi`, 
    `b`.`etki_tipi` AS `etki_tipi`, 
    CASE WHEN `e`.`yari_omur_saat` > 24 THEN 'Uzun Etkili' WHEN `e`.`yari_omur_saat` BETWEEN 12 AND 24 THEN 'Orta Etkili' ELSE 'Kısa Etkili' END AS `etki_suresi_riski` 
FROM `etken_madde` `e` 
JOIN `madde_sinif_iliski` `msi` ON `e`.`madde_id` = `msi`.`madde_id` 
JOIN `ilac_sinifi` `s` ON `msi`.`sinif_id` = `s`.`sinif_id` 
LEFT JOIN `baglanma_etkisi` `b` ON `e`.`madde_id` = `b`.`madde_id` 
LEFT JOIN `biyolojik_hedef` `h` ON `b`.`hedef_id` = `h`.`hedef_id`;

COMMIT;
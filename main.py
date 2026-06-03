import customtkinter as ctk
import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

def baglan():
    try:
        conn = mysql.connector.connect(
            host="localhost", 
            user="root",      
            password="",      
            database="farmakoloji_db"
        )
        return conn
    except mysql.connector.Error as err:
        messagebox.showerror("Hata", f"Bağlantı kurulamadı: {err}")
        return None

def ilaclari_getir():
    conn = baglan()
    if conn:
        cursor = conn.cursor()
        cursor.execute("SELECT madde_id, jenerik_isim, kimyasal_isim, molekul_agirligi, yari_omur_saat FROM etken_madde")
        satirlar = cursor.fetchall()
        
        for row in tree_crud.get_children():
            tree_crud.delete(row)
            
        for satir in satirlar:
            tree_crud.insert("", "end", values=satir)
        conn.close()

def tablo_satir_sec(event):
    secili = tree_crud.selection()
    if secili:
        satir = tree_crud.item(secili[0])['values']
        
        entry_jenerik.delete(0, tk.END)
        entry_jenerik.insert(0, satir[1])
        
        entry_kimyasal.delete(0, tk.END)
        entry_kimyasal.insert(0, satir[2])
        
        entry_agirlik.delete(0, tk.END)
        entry_agirlik.insert(0, satir[3])
        
        entry_saat.delete(0, tk.END)
        entry_saat.insert(0, satir[4])

def secimi_temizle():
    for item in tree_crud.selection():
        tree_crud.selection_remove(item)
    
    entry_jenerik.delete(0, tk.END)
    entry_kimyasal.delete(0, tk.END)
    entry_agirlik.delete(0, tk.END)
    entry_saat.delete(0, tk.END)

def ilac_ekle():
    jenerik = entry_jenerik.get()
    kimyasal = entry_kimyasal.get()
    agirlik = entry_agirlik.get()
    saat = entry_saat.get()
    
    if not jenerik or not kimyasal or not saat:
        messagebox.showwarning("Uyarı", "Lütfen bilgileri eksiksiz girin.")
        return

    conn = baglan()
    if conn:
        try:
            cursor = conn.cursor()
            sql = "INSERT INTO etken_madde (jenerik_isim, kimyasal_isim, molekul_agirligi, yari_omur_saat) VALUES (%s, %s, %s, %s)"
            cursor.execute(sql, (jenerik, kimyasal, float(agirlik), int(saat)))
            conn.commit()
            messagebox.showinfo("Başarılı", "İlaç sisteme başarıyla eklendi.")
            ilaclari_getir()
            secimi_temizle()
        except Exception as e:
            messagebox.showerror("Hata", f"Kayıt eklenemedi: {e}")
        finally:
            conn.close()

def ilac_guncelle():
    secili = tree_crud.selection()
    if not secili:
        messagebox.showwarning("Uyarı", "Lütfen güncellemek için listeden bir kayıt seçin.")
        return
    
    madde_id = tree_crud.item(secili[0])['values'][0]
    jenerik = entry_jenerik.get()
    kimyasal = entry_kimyasal.get()
    agirlik = entry_agirlik.get()
    saat = entry_saat.get()
    
    if not jenerik or not kimyasal or not saat:
        messagebox.showwarning("Uyarı", "Lütfen güncellenecek bilgileri eksiksiz bırakın.")
        return

    conn = baglan()
    if conn:
        try:
            cursor = conn.cursor()
            sql = "UPDATE etken_madde SET jenerik_isim=%s, kimyasal_isim=%s, molekul_agirligi=%s, yari_omur_saat=%s WHERE madde_id=%s"
            cursor.execute(sql, (jenerik, kimyasal, float(agirlik), int(saat), madde_id))
            conn.commit()
            messagebox.showinfo("Başarılı", "Kayıt başarıyla güncellendi.")
            ilaclari_getir()
            secimi_temizle()
        except Exception as e:
            messagebox.showerror("Hata", f"Kayıt güncellenemedi: {e}")
        finally:
            conn.close()

def ilac_sil():
    secili = tree_crud.selection()
    if not secili:
        messagebox.showwarning("Uyarı", "Listeden silmek istediğiniz ilacı seçin.")
        return
    
    madde_id = tree_crud.item(secili[0])['values'][0]
    
    cevap = messagebox.askyesno("Onay", "Bu ilacı ve bağlı olduğu tüm etkileşim kayıtlarını sistemden kalıcı olarak silmek istiyor musunuz?")
    if cevap:
        conn = baglan()
        if conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM etken_madde WHERE madde_id = %s", (madde_id,))
            conn.commit()
            conn.close()
            messagebox.showinfo("Bilgi", "Kayıt başarıyla silindi.")
            ilaclari_getir()
            secimi_temizle()

def sinifa_gore_ara():
    aranan = entry_sinif_ara.get()
    
    sql = """
    SELECT e.jenerik_isim, s.sinif_adi 
    FROM etken_madde e
    JOIN madde_sinif_iliski msi ON e.madde_id = msi.madde_id
    JOIN ilac_sinifi s ON msi.sinif_id = s.sinif_id
    WHERE s.sinif_adi LIKE %s
    """
    conn = baglan()
    if conn:
        cursor = conn.cursor()
        cursor.execute(sql, (f"%{aranan}%",))
        satirlar = cursor.fetchall()
        
        textbox_arama.delete("1.0", tk.END)
        for satir in satirlar:
            textbox_arama.insert(tk.END, f" İlaç: {satir[0]} | Sınıf: {satir[1]}\n")
        conn.close()

def enzim_istatistik_getir():
    aranan_enzim = entry_enzim_ara.get()
    
    sql = """
    SELECT k.enzim_adi, COUNT(m.madde_id) as ilac_sayisi
    FROM karaciger_enzimi k
    JOIN metabolik_profil m ON k.enzim_id = m.enzim_id
    WHERE k.enzim_adi LIKE %s
    GROUP BY k.enzim_adi
    """
    conn = baglan()
    if conn:
        cursor = conn.cursor()
        cursor.execute(sql, (f"%{aranan_enzim}%",))
        satirlar = cursor.fetchall()
        
        textbox_arama.delete("1.0", tk.END)
        if not satirlar:
            textbox_arama.insert(tk.END, "Bu enzimle etkileşime giren ilaç bulunamadı.")
        for satir in satirlar:
            textbox_arama.insert(tk.END, f" Enzim: {satir[0]} | İlaç Sayısı: {satir[1]}\n")
        conn.close()

def yordam_calistir():
    parametreler = []
    
    for e in sp_entry_listesi:
        val = e.get()
        # Eğer kontrol edilen kutucuk bir açılır listeyse ve ID içeriyorsa
        if isinstance(e, ctk.CTkComboBox):
            if val == "Seçiniz..." or val == "":
                messagebox.showwarning("Uyarı", "Lütfen listelerden geçerli bir Sınıf, Hedef ve Enzim seçin.")
                return
            # Metnin başındaki ID'yi al (Örn: "2 - SSRI" -> "2")
            if " - " in val:
                val = val.split(" - ")[0]
        
        parametreler.append(val)
    
    if "" in parametreler:
        messagebox.showwarning("Uyarı", "Hızlı kaydı tamamlamak için lütfen 10 alanın tamamını doldurun.")
        return
        
    conn = baglan()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.callproc('sp_kapsamli_ilac_ekle', parametreler)
            conn.commit()
            messagebox.showinfo("Başarılı", "Hızlı kayıt tamamlandı! İlaç ve tüm ilişkileri sisteme işlendi.")
            
            # Kayıt başarılı olunca kutuları temizle
            for e in sp_entry_listesi:
                if isinstance(e, ctk.CTkComboBox):
                    e.set("Seçiniz...")
                else:
                    e.delete(0, tk.END)
        except mysql.connector.Error as err:
            messagebox.showerror("Hata", f"İşlem başarısız:\n{err}")
        finally:
            conn.close()

def view_getir():
    conn = baglan()
    if conn:
        cursor = conn.cursor()
        cursor.execute("SELECT jenerik_isim_buyuk, kayit_tarihi, sisteme_ekleneli_kac_gun_oldu, sinif_adi, etki_suresi_riski FROM vw_ilac_genel_ozet")
        satirlar = cursor.fetchall()
        
        for row in tree_view.get_children():
            tree_view.delete(row)
            
        for satir in satirlar:
            tree_view.insert("", "end", values=satir)
        conn.close()

pencere = ctk.CTk()
pencere.title("PharmaCore - İlaç Etkileşim Yönetim Sistemi")
pencere.geometry("950x650")

sekmeler = ctk.CTkTabview(pencere, width=900, height=600)
sekmeler.pack(padx=20, pady=20, fill="both", expand=True)

sekme1 = sekmeler.add("İlaç Yönetimi")
sekme2 = sekmeler.add("Keşif ve Analiz")
sekme3 = sekmeler.add("Hızlı Kayıt")
sekme4 = sekmeler.add("Sistem Panosu (Dashboard)")

# --- SEKME 1 ---
frame_girdi = ctk.CTkFrame(sekme1)
frame_girdi.pack(fill="x", padx=10, pady=10)

entry_jenerik = ctk.CTkEntry(frame_girdi, placeholder_text="Jenerik İsim", width=200)
entry_jenerik.grid(row=0, column=0, padx=10, pady=10)

entry_kimyasal = ctk.CTkEntry(frame_girdi, placeholder_text="Kimyasal İsim", width=200)
entry_kimyasal.grid(row=0, column=1, padx=10, pady=10)

entry_agirlik = ctk.CTkEntry(frame_girdi, placeholder_text="Ağırlık", width=200)
entry_agirlik.grid(row=1, column=0, padx=10, pady=10)

entry_saat = ctk.CTkEntry(frame_girdi, placeholder_text="Yarı Ömür (Saat)", width=200)
entry_saat.grid(row=1, column=1, padx=10, pady=10)

frame_butonlar = ctk.CTkFrame(sekme1, fg_color="transparent")
frame_butonlar.pack(pady=5)

btn_ekle = ctk.CTkButton(frame_butonlar, text="Yeni Ekle", command=ilac_ekle, fg_color="green", width=120)
btn_ekle.grid(row=0, column=0, padx=5)

btn_guncelle = ctk.CTkButton(frame_butonlar, text="Seçili Kaydı Güncelle", command=ilac_guncelle, fg_color="#1f538d", width=160)
btn_guncelle.grid(row=0, column=1, padx=5)

btn_sil = ctk.CTkButton(frame_butonlar, text="Seçili Kaydı Sil", command=ilac_sil, fg_color="red", width=120)
btn_sil.grid(row=0, column=2, padx=5)

btn_temizle = ctk.CTkButton(frame_butonlar, text="Tercihi Kaldır", command=secimi_temizle, fg_color="gray", width=120)
btn_temizle.grid(row=0, column=3, padx=5)

style = ttk.Style()
style.theme_use("default")
style.configure("Treeview", 
                background="#2b2b2b", 
                foreground="white", 
                rowheight=25, 
                fieldbackground="#2b2b2b", 
                borderwidth=0,
                font=('Arial', 10))
style.map('Treeview', background=[('selected', '#1f538d')], foreground=[('selected', 'white')])
style.configure("Treeview.Heading", background="#1f538d", foreground="white", font=('Arial', 10, 'bold'))

tree_crud = ttk.Treeview(sekme1, columns=("ID", "Jenerik", "Kimyasal", "Ağırlık", "Saat"), show="headings", height=10)
for col in ("ID", "Jenerik", "Kimyasal", "Ağırlık", "Saat"):
    tree_crud.heading(col, text=col)
tree_crud.pack(fill="both", expand=True, padx=10, pady=10)

tree_crud.bind("<ButtonRelease-1>", tablo_satir_sec)
ilaclari_getir()

# --- SEKME 2 ---
frame_ara = ctk.CTkFrame(sekme2)
frame_ara.pack(fill="x", padx=10, pady=10)

ctk.CTkLabel(frame_ara, text="Sınıfa Göre Filtrele:").grid(row=0, column=0, padx=10, pady=10)
entry_sinif_ara = ctk.CTkEntry(frame_ara, placeholder_text="Örn: Beta Bloker")
entry_sinif_ara.grid(row=0, column=1, padx=10, pady=10)
ctk.CTkButton(frame_ara, text="Sonuçları Getir", command=sinifa_gore_ara).grid(row=0, column=2, padx=10)

ctk.CTkLabel(frame_ara, text="Enzim İstatistiği:").grid(row=1, column=0, padx=10, pady=10)
entry_enzim_ara = ctk.CTkEntry(frame_ara, placeholder_text="Örn: CYP3A4")
entry_enzim_ara.grid(row=1, column=1, padx=10, pady=10)
ctk.CTkButton(frame_ara, text="İstatistik Çıkar", command=enzim_istatistik_getir, fg_color="darkorange").grid(row=1, column=2, padx=10)

textbox_arama = ctk.CTkTextbox(sekme2, width=800, height=300, font=("Consolas", 14))
textbox_arama.pack(pady=20)

# --- SEKME 3: HIZLI KAYIT (Dinamik Dropdown) ---
ctk.CTkLabel(sekme3, text="Yeni İlaç ve Etkileşim Kayıt Formu", font=("Arial", 16, "bold")).pack(pady=10)
frame_sp = ctk.CTkFrame(sekme3)
frame_sp.pack(pady=10, padx=20, fill="both", expand=True)

# Veritabanından dropdown isimlerini çekme
siniflar, hedefler, enzimler = [], [], []
conn_sp = baglan()
if conn_sp:
    try:
        cursor_sp = conn_sp.cursor()
        cursor_sp.execute("SELECT sinif_id, sinif_adi FROM ilac_sinifi")
        siniflar = [f"{row[0]} - {row[1]}" for row in cursor_sp.fetchall()]
        
        cursor_sp.execute("SELECT hedef_id, hedef_adi FROM biyolojik_hedef")
        hedefler = [f"{row[0]} - {row[1]}" for row in cursor_sp.fetchall()]
        
        cursor_sp.execute("SELECT enzim_id, enzim_adi FROM karaciger_enzimi")
        enzimler = [f"{row[0]} - {row[1]}" for row in cursor_sp.fetchall()]
    except Exception as e:
        pass
    finally:
        conn_sp.close()

# Eğer bağlantı hatası varsa listeler boş kalmasın
if not siniflar: siniflar = ["1 - Sınıf Bulunamadı"]
if not hedefler: hedefler = ["1 - Hedef Bulunamadı"]
if not enzimler: enzimler = ["1 - Enzim Bulunamadı"]

# Etiketleri "ID" kelimesinden kurtarıp kullanıcı dostu yaptık
etiketler = ["1. Jenerik İsim:", "2. Kimyasal İsim:", "3. Mol. Ağırlığı:", "4. Yarı Ömür (Saat):", 
             "5. İlaç Sınıfı:", "6. Onay Yılı:", "7. Biyolojik Hedef:", "8. Etki Tipi:", 
             "9. Karaciğer Enzimi:", "10. Metabolik Rol:"]

sp_entry_listesi = []
for i, etiket in enumerate(etiketler):
    satir = i if i < 5 else i - 5
    sutun = 0 if i < 5 else 2
    
    ctk.CTkLabel(frame_sp, text=etiket).grid(row=satir, column=sutun, padx=10, pady=10, sticky="e")
    
    # 4, 6 ve 8. indexlerde (Sınıf, Hedef, Enzim) açılır liste göster
    if i == 4:
        e = ctk.CTkComboBox(frame_sp, width=200, values=siniflar)
        e.set("Seçiniz...")
    elif i == 6:
        e = ctk.CTkComboBox(frame_sp, width=200, values=hedefler)
        e.set("Seçiniz...")
    elif i == 8:
        e = ctk.CTkComboBox(frame_sp, width=200, values=enzimler)
        e.set("Seçiniz...")
    else:
        e = ctk.CTkEntry(frame_sp, width=200)
        
    e.grid(row=satir, column=sutun+1, padx=10, pady=10)
    sp_entry_listesi.append(e)

ctk.CTkButton(sekme3, text="Hızlı Kaydı Tamamla ve Kaydet", command=yordam_calistir, fg_color="purple", width=250, height=40).pack(pady=10)

# --- SEKME 4 ---
ctk.CTkButton(sekme4, text="Sistem Raporunu Güncelle", command=view_getir, fg_color="#006400", width=250, height=40).pack(pady=10)
tree_view = ttk.Treeview(sekme4, columns=("Jenerik", "Tarih", "Gun", "Sınıf", "Risk"), show="headings", height=15)
tree_view.heading("Jenerik", text="İlaç Adı")
tree_view.heading("Tarih", text="Kayıt Tarihi")
tree_view.heading("Gun", text="Gün")
tree_view.heading("Sınıf", text="Sınıfı")
tree_view.heading("Risk", text="Risk")
tree_view.pack(fill="both", expand=True, padx=10, pady=10)

pencere.mainloop()
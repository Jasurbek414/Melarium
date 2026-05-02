TEXNIK TOPSHIRIQ
Loyiha: MELARIUM (Agro Investment Platform)

1. LOYIHA MAQSADI
MELARIUM platformasi quyidagi imkoniyatlarni taqdim etadi:
• asalari koloniyalariga investitsiya qilish 
• pasikalarni boshqarish 
• asal ishlab chiqarishni kuzatish 
• investorlar uchun daromad olish tizimini yaratish 

2. FOYDALANUVCHI ROLLARI

2.1 Investor
• ro‘yxatdan o‘tish va tizimga kirish 
• koloniya yoki ulush sotib olish 
• daromadni kuzatish 
• asalni olish yoki sotish variantini tanlash 

2.2 Asalarichi
• koloniyalarni qo‘shish 
• ishlab chiqarish va xarajatlarni kiritish 
• koloniyalar holatini yangilash 

2.3 Administrator
• foydalanuvchilarni boshqarish 
• koloniyalarni moderatsiya qilish 
• to‘lovlar va operatsiyalarni nazorat qilish 

3. MVP FUNKSIYALARI

3.1 Avtorizatsiya
• telefon raqam orqali kirish 
• OTP tasdiqlash 
• rollar bo‘yicha ajratish 

3.2 Koloniyalar marketplace’i
Har bir koloniya uchun:
• ID 
• joylashuv 
• asalarichi 
• narx 
• kutilayotgan daromad (ROI) 

Funktsiyalar:
• ro‘yxatni ko‘rish 
• sotib olish yoki bron qilish 

3.3 Investor kabineti
• sotib olingan koloniyalar 
• investitsiya summasi 
• kutilayotgan daromad 
• holat (aktiv, yig‘im jarayoni, yakunlangan) 

3.4 Asalarichi kabineti
• koloniya qo‘shish 
• ma’lumotlarni tahrirlash 
• quyidagilarni kiritish: 
o ishlab chiqarilgan asal hajmi 
o xarajatlar 
o holat 

3.5 Asal hisoboti
• “yig‘ildi” deb belgilash 
• investor tanlovi: 
o yetkazib berish 
o sotish 

3.6 Admin panel
• foydalanuvchilar ro‘yxati 
• koloniyalar ro‘yxati 
• savdolarni nazorat qilish 

3.7 IoT simulyatsiya
(hozircha qo‘lda kiritiladi)
• harorat 
• namlik 
• vazn 

4. TO‘LOV TIZIMI
Integratsiya:
• Click 
• Payme 
• Uzcard 
• Humo 

Funktsiyalar:
• to‘lovni amalga oshirish 
• tranzaksiya holatini kuzatish 
• webhook orqali tasdiqlash 

5. XABARNOMALAR
• SMS 
• Push bildirishnomalar 

Triggerlar:
• sotib olish 
• asal yig‘ilishi 
• holat o‘zgarishi 

6. ANALITIKA (boshlang‘ich)
• umumiy investitsiya 
• kutilayotgan daromad 
• ishlab chiqarilgan asal hajmi 

7. XAVFSIZLIK
• HTTPS 
• JWT asosida avtorizatsiya 
• foydalanuvchi harakatlarini loglash 

8. ARXITEKTURA

Backend:
• JAVA
• REST API 

Frontend:
• Web (React) 
• mobil ilova (Flutter) 

Ma’lumotlar bazasi:
• PostgreSQL 

9. PRODUCTION BOSQICHI

IoT integratsiya
• real sensorlar (harorat, namlik, vazn, ovoz) 
• MQTT yoki WebSocket orqali real vaqt ma’lumotlari 

Kengaytirilgan analitika
• real ROI 
• foyda va zarar 
• koloniya sog‘lomlik indeksi 

Asal marketplace
• mahsulotni sotish 
• platforma komissiyasi 10–15% 

Masshtablash
• 100 000+ foydalanuvchi 
• navbat tizimi (RabbitMQ yoki Kafka) 

10. MONETIZATSIYA
• investitsiyalardan 5–10% komissiya 
• asal savdosidan 10–15% komissiya 

11. MVP CHEKLOVLARI
• real IoT mavjud emas 
• avtomatik analitika yo‘q 
• ma’lumotlar qo‘lda kiritiladi 
• interfeys soddalashtirilgan 

12. ASOSIY KO‘RSATKICHLAR (KPI)
• investorlar soni 
• aktiv koloniyalar soni 
• platforma aylanmasi 
• foydalanuvchi qiymati (LTV)

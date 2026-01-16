import asyncio
import aiosqlite

class Database:

    @staticmethod
    async def Connect():
        db = await aiosqlite.connect("database.db")
        await db.execute("""
            CREATE TABLE IF NOT EXISTS database (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pub_key TEXT,
                pv_key TEXT,
                aes TEXT,
                enc_photo TEXT
            )
        """)
        await db.commit()
        return db

    @staticmethod
    async def Insert(db, **values):
        if not values:
            return

        columns = ", ".join(values.keys())
        placeholders = ", ".join("?" for _ in values)
        sql = f"INSERT INTO database ({columns}) VALUES ({placeholders})"

        await db.execute(sql, tuple(values.values()))
        await db.commit()

    @staticmethod
    async def main():
        db = await Database.Connect()

        await Database.Insert(
            db,
            pub_key="public_key_here",
            aes="aes_key_here"
        )

        await Database.Insert(
            db,
            enc_photo="encrypted_photo_data"
        )

        await db.close()
        print("✓ Database operations completed successfully!")

if __name__ == "__main__":
    asyncio.run(Database.main())

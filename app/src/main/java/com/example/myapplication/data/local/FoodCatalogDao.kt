package com.example.myapplication.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface FoodCatalogDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(foods: List<FoodCatalogEntity>)

    @Query("SELECT * FROM food_catalog ORDER BY name ASC")
    fun observeAll(): Flow<List<FoodCatalogEntity>>

    @Query("SELECT * FROM food_catalog WHERE name LIKE '%' || :query || '%' ORDER BY name ASC")
    fun searchByName(query: String): Flow<List<FoodCatalogEntity>>

    @Query("SELECT * FROM food_catalog ORDER BY name ASC")
    suspend fun getAllNow(): List<FoodCatalogEntity>

    @Query("DELETE FROM food_catalog WHERE importBatchId = :batchId")
    suspend fun deleteByBatch(batchId: String)

    @Query("DELETE FROM food_catalog")
    suspend fun deleteAll()

    @Query("SELECT COUNT(*) FROM food_catalog")
    suspend fun countAll(): Int

    @Query("SELECT COUNT(*) FROM food_catalog")
    fun observeCount(): Flow<Int>

    @Query("UPDATE food_catalog SET isFavorite = :isFavorite WHERE id = :id")
    suspend fun toggleFavorite(id: Long, isFavorite: Boolean): Int

    @Query("SELECT * FROM food_catalog WHERE isFavorite = 1 ORDER BY name ASC")
    fun observeFavorites(): Flow<List<FoodCatalogEntity>>

    @Query("SELECT * FROM food_catalog WHERE isFavorite = 1 AND name LIKE '%' || :query || '%' ORDER BY name ASC")
    fun searchFavorites(query: String): Flow<List<FoodCatalogEntity>>
}

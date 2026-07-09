package com.example.myapplication.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface LoggedFoodDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(loggedFood: LoggedFoodEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(loggedFoods: List<LoggedFoodEntity>)

    @Query("SELECT * FROM logged_foods WHERE id = :id LIMIT 1")
    suspend fun getById(id: Long): LoggedFoodEntity?

    @Query("DELETE FROM logged_foods WHERE id = :id")
    suspend fun delete(id: Long): Int

    @Query("SELECT * FROM logged_foods WHERE epochDay = :epochDay ORDER BY timestamp ASC")
    fun observeDay(epochDay: Long): Flow<List<LoggedFoodEntity>>

    @Query("SELECT * FROM logged_foods WHERE epochDay = :epochDay ORDER BY timestamp ASC")
    suspend fun dayNow(epochDay: Long): List<LoggedFoodEntity>

    @Query("SELECT * FROM logged_foods ORDER BY timestamp DESC LIMIT :limit")
    fun observeRecentFoods(limit: Int): Flow<List<LoggedFoodEntity>>

    @Query("SELECT * FROM logged_foods ORDER BY timestamp DESC LIMIT :limit")
    suspend fun recentFoodsNow(limit: Int): List<LoggedFoodEntity>

    @Query("DELETE FROM logged_foods")
    suspend fun deleteAll()
}

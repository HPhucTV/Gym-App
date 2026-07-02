package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import com.example.myapplication.core.adaptation.AdaptationKind
import com.example.myapplication.core.adaptation.AdaptationMode
import com.example.myapplication.core.adaptation.AdaptationStatus

@Entity(
    tableName = "adaptation_decisions",
    indices = [
        Index(value = ["status", "createdAtEpochMillis"]),
        Index(value = ["kind", "createdAtEpochMillis"]),
    ],
)
data class AdaptationDecisionEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val kind: AdaptationKind,
    val mode: AdaptationMode,
    val status: AdaptationStatus,
    val reasonVi: String,
    val payloadVersion: Int,
    val inputsJson: String,
    val beforeJson: String,
    val afterJson: String,
    val undoJson: String,
    val createdAtEpochMillis: Long,
    val resolvedAtEpochMillis: Long?,
)

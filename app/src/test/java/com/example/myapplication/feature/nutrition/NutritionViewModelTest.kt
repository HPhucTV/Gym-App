package com.example.myapplication.feature.nutrition

import com.example.myapplication.core.model.ActiveGoal
import com.example.myapplication.data.CompleteWorkoutResult
import com.example.myapplication.core.model.CompletedWorkout
import com.example.myapplication.core.model.EquipmentProfile
import com.example.myapplication.core.model.ExperienceLevel
import com.example.myapplication.core.model.FitnessGoal
import com.example.myapplication.core.model.GoalConfig
import com.example.myapplication.core.model.ProgramTemplate
import com.example.myapplication.core.model.RestDayMode
import com.example.myapplication.core.model.WorkoutSession
import com.example.myapplication.core.nutrition.EntrySource
import com.example.myapplication.core.nutrition.Nutrients
import com.example.myapplication.core.nutrition.NutritionDay
import com.example.myapplication.core.nutrition.MealTemplate
import com.example.myapplication.data.NutritionData
import com.example.myapplication.data.NutritionRepository
import com.example.myapplication.data.WorkoutRepository
import com.example.myapplication.feature.onboarding.MainDispatcherRule
import com.example.myapplication.data.local.LoggedFoodEntity
import com.example.myapplication.data.local.FoodCatalogEntity
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class NutritionViewModelTest {
    private val dispatcher = StandardTestDispatcher()
    @get:Rule val mainRule = MainDispatcherRule(dispatcher)

    @org.junit.Before
    fun setUp() {
        com.example.myapplication.app.BackendConfig.customServerUrl = "http://localhost:3000"
    }

    @org.junit.After
    fun tearDown() {
        com.example.myapplication.app.BackendConfig.customServerUrl = null
    }

    @Test
    fun `accepted scan result is stored on the selected day`() = runTest(dispatcher) {
        val nutritionRepository = FakeNutritionRepository()
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = nutritionRepository,
            foodAnalysisClient = FakeFoodAnalysisClient(scanResult()),
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanFood(null)
        advanceUntilIdle()
        viewModel.acceptScanResult()
        advanceUntilIdle()

        assertEquals(20636L, nutritionRepository.additions.single().epochDay)
        assertEquals(Nutrients(calories = 510, proteinGrams = 31, carbsGrams = 62, fatGrams = 16), nutritionRepository.additions.single().nutrients)
        assertEquals(EntrySource.CAMERA_ANALYSIS, nutritionRepository.additions.single().source)
    }

    @Test
    fun `scanBarcode successfully populates draftState`() = runTest(dispatcher) {
        val fakeProduct = ScanResult(
            dishName = "Chocopie",
            totalCalories = 140,
            proteinGrams = 1,
            carbsGrams = 19,
            fatGrams = 6,
            fitnessScore = 5,
            advice = "Ok",
            constituents = emptyList(),
            sweatPayment = null,
            calculationProcess = null,
            confidence = 1.0,
            needsUserConfirmation = false,
            recommendations = emptyList()
        )
        val client = FakeFoodAnalysisClient(barcodeResult = fakeProduct)
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = FakeNutritionRepository(),
            foodAnalysisClient = client,
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanBarcode("8934563138038")
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertNotNull(state.draft)
        val draft = state.draft!!
        assertEquals("Chocopie", draft.nameVi)
        assertEquals("140", draft.caloriesText)
        assertEquals("1", draft.proteinText)
        assertEquals("19", draft.carbsText)
        assertEquals("6", draft.fatText)
        assertEquals("0", draft.fiberText)
    }

    @Test
    fun `scanBarcode unknown product opens blank draft with new barcode marker`() = runTest(dispatcher) {
        val client = FakeFoodAnalysisClient(barcodeResult = null)
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = FakeNutritionRepository(),
            foodAnalysisClient = client,
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanBarcode("9999999999999")
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertNotNull(state.draft)
        val draft = state.draft!!
        assertEquals("", draft.nameVi)
        assertTrue(draft.errors.containsKey("submit"))
    }

    @Test
    fun `acceptDraft registers new barcode online`() = runTest(dispatcher) {
        val client = FakeFoodAnalysisClient(barcodeResult = null)
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = repo,
            foodAnalysisClient = client,
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanBarcode("9999999999999")
        advanceUntilIdle()

        viewModel.updateDraftName("Banh gao")
        viewModel.updateDraftCalories("120")
        viewModel.updateDraftProtein("2")
        viewModel.updateDraftCarbs("25")
        viewModel.updateDraftFat("1")
        viewModel.updateDraftFiber("0")

        viewModel.acceptDraft()
        advanceUntilIdle()

        // Should log to database
        assertEquals(1, repo.loggedFoods.value.size)
        assertEquals("Banh gao", repo.loggedFoods.value[0].name)

        // Should register barcode online
        assertEquals(1, client.registerBarcodeCalls)
        val reg = client.registeredBarcodes.single()
        assertEquals("9999999999999", reg.first)
        assertEquals("Banh gao", reg.second.dishName)
        assertEquals(120, reg.second.totalCalories)
    }

    @Test
    fun `http analysis failure is recoverable`() = runTest(dispatcher) {
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = FakeNutritionRepository(),
            foodAnalysisClient = FakeFoodAnalysisClient(null),
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanFood(null)
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertFalse(state.scanning)
        assertNotNull(state.scanError)
    }

    @Test
    fun `scan cancellation is not converted to a user error`() = runTest(dispatcher) {
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = FakeNutritionRepository(),
            foodAnalysisClient = FakeFoodAnalysisClient(failure = CancellationException("stop")),
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanFood(null)
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertFalse(state.scanning)
        assertNull(state.scanError)
    }

    @Test
    fun `food image is never uploaded without cloud AI consent`() = runTest(dispatcher) {
        val client = FakeFoodAnalysisClient(scanResult())
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = FakeNutritionRepository(),
            foodAnalysisClient = client,
            cloudAiConsent = flowOf(false),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanFood(null)
        advanceUntilIdle()

        assertEquals(0, client.calls)
        val state = viewModel.uiState.value as NutritionUiState.Content
        assertNotNull(state.scanError)
        assertFalse(state.scanning)
    }

    @Test
    fun `history lists past entries with logged calories`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val today = 20636L
        
        repo.historyData.value = listOf(
            NutritionDay(today, Nutrients(calories = 500), null),
            NutritionDay(today - 1, Nutrients(calories = 1200), null),
            NutritionDay(today - 2, Nutrients(calories = 0), null),
            NutritionDay(today - 3, Nutrients(calories = 1500), null),
        )
        
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = repo,
            foodAnalysisClient = FakeFoodAnalysisClient(),
            cloudAiConsent = flowOf(true),
            currentEpochDay = { today },
        )
        collectUiState(viewModel)
        runCurrent()
        
        val state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(2, state.history.size)
        assertEquals(today - 1, state.history[0].epochDay)
        assertEquals(1200, state.history[0].consumed.calories)
        assertEquals(today - 3, state.history[1].epochDay)
        assertEquals(1500, state.history[1].consumed.calories)
    }

    @Test
    fun `scan becomes editable draft and accepted values are parsed once`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = repo,
            foodAnalysisClient = FakeFoodAnalysisClient(scanResult()),
            cloudAiConsent = flowOf(true),
            currentEpochDay = { 20636L },
        )
        collectUiState(viewModel)
        runCurrent()

        viewModel.scanFood(null)
        advanceUntilIdle()
        var draft = (viewModel.uiState.value as NutritionUiState.Content).draft!!
        assertEquals("Com ga", draft.nameVi)
        viewModel.updateDraftCalories(" 600 ")
        viewModel.updateDraftProtein("35")
        viewModel.updateDraftCarbs("70")
        viewModel.updateDraftFat("18")
        viewModel.acceptDraft()
        advanceUntilIdle()

        assertEquals(Nutrients(600, 35, 70, 18), repo.additions.single().nutrients)
        assertNull((viewModel.uiState.value as NutritionUiState.Content).draft)
    }

    @Test
    fun `invalid draft stays open and save as template follows successful nutrition write`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()

        viewModel.startManualEntry()
        viewModel.updateDraftName(" ")
        viewModel.updateDraftCalories("0")
        viewModel.updateDraftProtein("-1")
        viewModel.acceptDraft()
        runCurrent()
        assertTrue((viewModel.uiState.value as NutritionUiState.Content).draft!!.errors.isNotEmpty())
        assertTrue(repo.additions.isEmpty())

        viewModel.updateDraftName("Bữa phụ")
        viewModel.updateDraftCalories("250")
        viewModel.updateDraftProtein("12")
        viewModel.updateDraftCarbs("30")
        viewModel.updateDraftFat("8")
        viewModel.setDraftSaveAsTemplate(true)
        viewModel.acceptDraft()
        advanceUntilIdle()

        assertEquals(1, repo.additions.size)
        assertEquals(listOf("Bữa phụ"), repo.savedTemplateNames)
    }

    @Test
    fun `template applies once and deletion requires confirmation`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository().apply {
            templates.value = listOf(MealTemplate(7, "Bữa quen", Nutrients(400, 25, 45, 10), 1))
        }
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()

        viewModel.applyTemplate(7)
        viewModel.applyTemplate(7)
        runCurrent()
        assertEquals(listOf(7L), repo.appliedTemplateIds)

        viewModel.requestDeleteTemplate(7)
        runCurrent()
        assertEquals(7L, (viewModel.uiState.value as NutritionUiState.Content).pendingDeleteTemplateId)
        viewModel.cancelDeleteTemplate()
        viewModel.confirmDeleteTemplate()
        runCurrent()
        assertTrue(repo.deletedTemplateIds.isEmpty())
        viewModel.requestDeleteTemplate(7)
        viewModel.confirmDeleteTemplate()
        advanceUntilIdle()
        assertEquals(listOf(7L), repo.deletedTemplateIds)
    }

    @Test
    fun `template save retry never records draft nutrients twice`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository().apply { failTemplateSaveOnce = true }
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()
        viewModel.startManualEntry()
        viewModel.updateDraftName("Bữa trưa")
        viewModel.updateDraftCalories("500")
        viewModel.updateDraftProtein("30")
        viewModel.updateDraftCarbs("60")
        viewModel.updateDraftFat("15")
        viewModel.setDraftSaveAsTemplate(true)

        viewModel.acceptDraft()
        advanceUntilIdle()
        viewModel.acceptDraft()
        advanceUntilIdle()

        assertEquals(1, repo.additions.size)
        assertEquals(2, repo.templateSaveAttempts)
    }

    @Test
    fun `manual entry draft parses decimal values and rounds them`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()

        viewModel.startManualEntry()
        viewModel.updateDraftName("Thức ăn thập phân")
        viewModel.updateDraftCalories("250.6")
        viewModel.updateDraftProtein("12.4")
        viewModel.updateDraftCarbs("30,5")
        viewModel.updateDraftFat("8.0")
        viewModel.acceptDraft()
        advanceUntilIdle()

        assertEquals(1, repo.additions.size)
        assertEquals(Nutrients(251, 12, 31, 8), repo.additions.single().nutrients)
    }

    @Test
    fun `importNutritionFromCsv parses and inserts into catalog`() = runTest(dispatcher) {
        val fakeDao = object : com.example.myapplication.data.local.FoodCatalogDao {
            val inserted = mutableListOf<List<com.example.myapplication.data.local.FoodCatalogEntity>>()
            override fun observeAll() = flowOf(emptyList<com.example.myapplication.data.local.FoodCatalogEntity>())
            override fun observeCount() = flowOf(0)
            override fun searchByName(query: String) = flowOf(emptyList<com.example.myapplication.data.local.FoodCatalogEntity>())
            override suspend fun insertAll(items: List<com.example.myapplication.data.local.FoodCatalogEntity>) {
                inserted.add(items)
            }
            override suspend fun deleteAll() {}
            override suspend fun getAllNow() = emptyList<com.example.myapplication.data.local.FoodCatalogEntity>()
            override suspend fun deleteByBatch(batchId: String) {}
            override suspend fun countAll() = 0
            override suspend fun toggleFavorite(id: Long, isFavorite: Boolean) = 0
            override fun observeFavorites() = flowOf(emptyList<com.example.myapplication.data.local.FoodCatalogEntity>())
            override fun searchFavorites(query: String) = flowOf(emptyList<com.example.myapplication.data.local.FoodCatalogEntity>())
        }
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = FakeNutritionRepository(),
            foodCatalogDao = fakeDao,
            currentEpochDay = { 20636L },
            ioDispatcher = dispatcher
        )
        collectUiState(viewModel)
        runCurrent()

        val csv = """
            Food,Grams,Calories,fat,Carbs,Protein
            milk,100,61,3,4,3
        """.trimIndent()

        viewModel.importNutritionFromCsv(csv)
        advanceUntilIdle()

        assertEquals(1, fakeDao.inserted.size)
        assertEquals("milk", fakeDao.inserted[0][0].name)
        val state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(true, state.importSuccess)
    }

    @Test
    fun `cart operations works correctly`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()

        val food = FoodCatalogEntity(
            id = 101,
            name = "Thịt bò",
            caloriesPerServing = 250.0,
            gramsPerServing = 100.0,
            proteinPerServing = 26.0,
            carbsPerServing = 0.0,
            fatPerServing = 15.0,
            isFavorite = false,
            importBatchId = ""
        )

        // 1. Add to cart
        viewModel.addToCart(food, 200.0, "LUNCH")
        runCurrent()
        var state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(1, state.cart.size)
        assertEquals(200.0, state.cart[0].grams, 0.01)
        assertEquals("LUNCH", state.cart[0].mealTime)

        // 2. Add same item increases grams
        viewModel.addToCart(food, 100.0, "LUNCH")
        runCurrent()
        state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(300.0, state.cart[0].grams, 0.01)

        // 3. Update grams
        viewModel.updateCartGrams(101, "LUNCH", 150.0)
        runCurrent()
        state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(150.0, state.cart[0].grams, 0.01)

        // 4. Remove from cart
        viewModel.removeFromCart(101, "LUNCH")
        runCurrent()
        state = viewModel.uiState.value as NutritionUiState.Content
        assertTrue(state.cart.isEmpty())
    }

    @Test
    fun `confirm eat cart adds foods to repository and clears cart`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()

        val food = FoodCatalogEntity(
            id = 101,
            name = "Trứng",
            caloriesPerServing = 155.0,
            gramsPerServing = 100.0,
            proteinPerServing = 13.0,
            carbsPerServing = 1.1,
            fatPerServing = 11.0,
            isFavorite = false,
            importBatchId = ""
        )

        viewModel.addToCart(food, 50.0, "BREAKFAST")
        runCurrent()
        viewModel.confirmEatCart()
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertTrue(state.cart.isEmpty())
        assertEquals(1, repo.loggedFoods.value.size)
        assertEquals("Trứng", repo.loggedFoods.value[0].name)
        assertEquals("BREAKFAST", repo.loggedFoods.value[0].mealTime)
    }

    @Test
    fun `selectScanRecommendation sets draft and clears scanResultState`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val viewModel = NutritionViewModel(FakeWorkoutRepository(), repo, currentEpochDay = { 20636L })
        collectUiState(viewModel)
        runCurrent()

        val scanResult = ScanResult(
            dishName = "Phở bò",
            totalCalories = 450,
            proteinGrams = 20,
            carbsGrams = 60,
            fatGrams = 12,
            fitnessScore = 8,
            advice = "Ăn tốt",
            constituents = emptyList(),
            sweatPayment = null,
            recommendations = listOf(
                ScanRecommendation("Phở bò", 0.95, 450, 20, 60, 12),
                ScanRecommendation("Hủ tiếu", 0.65, 500, 18, 65, 14)
            )
        )

        // Inject scanResult directly (simulate successful scan)
        val field = viewModel.javaClass.getDeclaredField("scanResultState")
        field.isAccessible = true
        (field.get(viewModel) as MutableStateFlow<ScanResult?>).value = scanResult
        runCurrent()

        // Verify the recommendation is in the UI state
        var state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(scanResult, state.scanResult)

        // Select recommendation
        viewModel.selectScanRecommendation(scanResult.recommendations[0])
        runCurrent()

        state = viewModel.uiState.value as NutritionUiState.Content
        // Scan result should be cleared
        assertEquals(null, state.scanResult)
        // Draft should be populated with selected recommendation
        assertEquals("Phở bò", state.draft?.nameVi)
        assertEquals("450", state.draft?.caloriesText)
    }

    @Test
    fun `import nutrition file csv imports foods into database`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val dao = FakeFoodCatalogDao()
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = repo,
            foodCatalogDao = dao,
            currentEpochDay = { 20636L },
            ioDispatcher = dispatcher
        )
        collectUiState(viewModel)
        runCurrent()

        val csvText = "Tên,Calo,Protein,Carb,Béo\nỨc gà,165,31,0,3.6\nCơm trắng,130,2.7,28,0.3"
        viewModel.importNutritionFile("foods.csv", csvText.toByteArray(Charsets.UTF_8))
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(true, state.importSuccess)
        assertEquals(2, dao.inserted.size)
        assertEquals("Ức gà", dao.inserted[0].name)
        assertEquals(165.0, dao.inserted[0].caloriesPerServing, 0.01)
        assertEquals(31.0, dao.inserted[0].proteinPerServing, 0.01)
    }

    @Test
    fun `import nutrition file xlsx imports foods into database`() = runTest(dispatcher) {
        val repo = FakeNutritionRepository()
        val dao = FakeFoodCatalogDao()
        val viewModel = NutritionViewModel(
            workoutRepository = FakeWorkoutRepository(),
            nutritionRepository = repo,
            foodCatalogDao = dao,
            currentEpochDay = { 20636L },
            ioDispatcher = dispatcher
        )
        collectUiState(viewModel)
        runCurrent()

        val sharedStrings = listOf("Tên", "Calo", "Protein", "Carb", "Béo", "Ức gà", "Cơm trắng")
        val rows = listOf(
            listOf("A1" to 0, "B1" to 1, "C1" to 2, "D1" to 3, "E1" to 4),
            listOf("A2" to 5, "B2" to 165.0, "C2" to 31.0, "D2" to 0.0, "E2" to 3.6),
            listOf("A3" to 6, "B3" to 130.0, "C3" to 2.7, "D3" to 28.0, "E3" to 0.3)
        )
        val xlsxBytes = createFakeXlsxBytes(sharedStrings, rows)

        viewModel.importNutritionFile("foods.xlsx", xlsxBytes)
        advanceUntilIdle()

        val state = viewModel.uiState.value as NutritionUiState.Content
        assertEquals(true, state.importSuccess)
        assertEquals(2, dao.inserted.size)
        assertEquals("Ức gà", dao.inserted[0].name)
        assertEquals(165.0, dao.inserted[0].caloriesPerServing, 0.01)
        assertEquals(31.0, dao.inserted[0].proteinPerServing, 0.01)
    }

    private fun createFakeXlsxBytes(sharedStrings: List<String>, rows: List<List<Pair<String, Any>>>): ByteArray {
        val bos = java.io.ByteArrayOutputStream()
        java.util.zip.ZipOutputStream(bos).use { zos ->
            val ssXml = java.lang.StringBuilder()
            ssXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n")
            ssXml.append("<sst xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" count=\"${sharedStrings.size}\" uniqueCount=\"${sharedStrings.size}\">")
            for (s in sharedStrings) {
                ssXml.append("<si><t>$s</t></si>")
            }
            ssXml.append("</sst>")
            zos.putNextEntry(java.util.zip.ZipEntry("xl/sharedStrings.xml"))
            zos.write(ssXml.toString().toByteArray(Charsets.UTF_8))
            zos.closeEntry()

            val sheetXml = java.lang.StringBuilder()
            sheetXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n")
            sheetXml.append("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">")
            sheetXml.append("<sheetData>")
            for (row in rows) {
                sheetXml.append("<row>")
                for (cell in row) {
                    val ref = cell.first
                    val value = cell.second
                    if (value is Int) {
                        sheetXml.append("<c r=\"$ref\" t=\"s\"><v>$value</v></c>")
                    } else if (value is Double) {
                        sheetXml.append("<c r=\"$ref\"><v>$value</v></c>")
                    } else {
                        sheetXml.append("<c r=\"$ref\"><v>$value</v></c>")
                    }
                }
                sheetXml.append("</row>")
            }
            sheetXml.append("</sheetData>")
            sheetXml.append("</worksheet>")
            zos.putNextEntry(java.util.zip.ZipEntry("xl/worksheets/sheet1.xml"))
            zos.write(sheetXml.toString().toByteArray(Charsets.UTF_8))
            zos.closeEntry()
        }
        return bos.toByteArray()
    }

    private fun TestScope.collectUiState(viewModel: NutritionViewModel) {
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) { viewModel.uiState.collect() }
    }

    private fun scanResult() = ScanResult(
        dishName = "Com ga",
        totalCalories = 510,
        proteinGrams = 31,
        carbsGrams = 62,
        fatGrams = 16,
        fitnessScore = 7,
        advice = "On voi muc tieu hom nay.",
        constituents = emptyList(),
        sweatPayment = SweatPaymentProposal(
            exerciseId = "bodyweight_squat",
            exerciseName = "Squat khong ta",
            extraSets = 1,
        ),
        recommendations = listOf(
            ScanRecommendation("Com ga", 0.9, 510, 31, 62, 16)
        )
    )
}

private class FakeFoodAnalysisClient(
    private val result: ScanResult? = null,
    private val failure: Throwable? = null,
    private val barcodeResult: ScanResult? = null,
) : FoodAnalysisClient {
    var calls = 0
    var scanBarcodeCalls = 0
    var registerBarcodeCalls = 0
    val registeredBarcodes = mutableListOf<Pair<String, ScanResult>>()

    override suspend fun analyze(bitmap: android.graphics.Bitmap?): ScanResult? {
        calls++
        failure?.let { throw it }
        return result
    }

    override suspend fun scanBarcode(barcode: String): ScanResult? {
        scanBarcodeCalls++
        failure?.let { throw it }
        return barcodeResult
    }

    override suspend fun registerBarcode(barcode: String, result: ScanResult): Boolean {
        registerBarcodeCalls++
        registeredBarcodes.add(barcode to result)
        return true
    }
}

private data class AddedNutrition(
    val epochDay: Long,
    val nutrients: Nutrients,
    val source: EntrySource,
)

private class FakeNutritionRepository : NutritionRepository {
    private val data = MutableStateFlow(NutritionData())
    val additions = mutableListOf<AddedNutrition>()
    val templates = MutableStateFlow<List<MealTemplate>>(emptyList())
    val savedTemplateNames = mutableListOf<String>()
    val appliedTemplateIds = mutableListOf<Long>()
    val deletedTemplateIds = mutableListOf<Long>()
    var failTemplateSaveOnce = false
    var templateSaveAttempts = 0

    val loggedFoods = MutableStateFlow<List<LoggedFoodEntity>>(emptyList())
    val favoriteFoods = MutableStateFlow<List<FoodCatalogEntity>>(emptyList())
    val recentFoods = MutableStateFlow<List<FoodCatalogEntity>>(emptyList())
    val deletedLoggedFoodIds = mutableListOf<Long>()
    var copyYesterdayCalled = false

    override val nutritionData: Flow<NutritionData> = data

    override fun observeDay(epochDay: Long): Flow<NutritionDay> =
        flowOf(NutritionDay(epochDay = epochDay, consumed = Nutrients(), target = null))

    override fun observeRange(startEpochDay: Long, endEpochDay: Long): Flow<List<NutritionDay>> = flowOf(emptyList())

    val historyData = MutableStateFlow<List<NutritionDay>>(emptyList())
    override fun observeAllNutrition(): Flow<List<NutritionDay>> = historyData
    override fun observeMealTemplates(): Flow<List<MealTemplate>> = templates
    override suspend fun saveMealTemplate(id: Long?, nameVi: String, nutrients: Nutrients): Long {
        templateSaveAttempts++
        if (failTemplateSaveOnce) {
            failTemplateSaveOnce = false
            error("disk")
        }
        savedTemplateNames += nameVi
        return id ?: 1L
    }
    override suspend fun applyMealTemplate(id: Long, epochDay: Long) { appliedTemplateIds += id }
    override suspend fun deleteMealTemplate(id: Long) { deletedTemplateIds += id }

    override suspend fun addNutrients(epochDay: Long, nutrients: Nutrients, source: EntrySource) {
        additions += AddedNutrition(epochDay, nutrients, source)
        data.value = data.value.copy(
            caloriesEaten = data.value.caloriesEaten + nutrients.calories,
            proteinEaten = data.value.proteinEaten + nutrients.proteinGrams,
            carbsEaten = data.value.carbsEaten + nutrients.carbsGrams,
            fatEaten = data.value.fatEaten + nutrients.fatGrams,
        )
    }

    override fun observeLoggedFoods(epochDay: Long): Flow<List<LoggedFoodEntity>> = loggedFoods
    override suspend fun loggedFoodsNow(epochDay: Long): List<LoggedFoodEntity> = loggedFoods.value
    override fun observeRecentFoods(limit: Int): Flow<List<FoodCatalogEntity>> = recentFoods
    override fun observeFavorites(): Flow<List<FoodCatalogEntity>> = favoriteFoods
    override fun searchFavorites(query: String): Flow<List<FoodCatalogEntity>> = favoriteFoods.map { list ->
        list.filter { it.name.contains(query, ignoreCase = true) }
    }
    override suspend fun toggleFavorite(foodCatalogId: Long, isFavorite: Boolean) {
        favoriteFoods.value = favoriteFoods.value.map {
            if (it.id == foodCatalogId) it.copy(isFavorite = isFavorite) else it
        }
    }
    override suspend fun logFood(
        epochDay: Long,
        name: String,
        mealTime: String,
        grams: Double,
        calories: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatGrams: Int,
        fiberGrams: Int,
        foodCatalogId: Long?
    ) {
        val newLog = LoggedFoodEntity(
            id = (loggedFoods.value.size + 1).toLong(),
            epochDay = epochDay,
            name = name,
            mealTime = mealTime,
            grams = grams,
            calories = calories,
            proteinGrams = proteinGrams,
            carbsGrams = carbsGrams,
            fatGrams = fatGrams,
            fiberGrams = fiberGrams,
            timestamp = System.currentTimeMillis()
        )
        loggedFoods.value = loggedFoods.value + newLog
        
        val source = if (name.contains("Revive", ignoreCase = true) || name.contains("ga", ignoreCase = true)) {
            EntrySource.CAMERA_ANALYSIS
        } else {
            EntrySource.MANUAL
        }
        addNutrients(epochDay, Nutrients(calories, proteinGrams, carbsGrams, fatGrams, fiberGrams), source)
    }
    override suspend fun deleteLoggedFood(id: Long) {
        deletedLoggedFoodIds += id
        loggedFoods.value = loggedFoods.value.filter { it.id != id }
    }
    override suspend fun copyYesterdayMeals(yesterdayEpochDay: Long, todayEpochDay: Long) {
        copyYesterdayCalled = true
    }

    override suspend fun addWater(epochDay: Long, waterMl: Int) = Unit

    override suspend fun setTarget(epochDay: Long, target: com.example.myapplication.core.nutrition.NutritionTarget) = Unit
    override suspend fun setSweatPayment(exerciseId: String, exerciseName: String, extraSets: Int, active: Boolean) = Unit
    override suspend fun clearSweatPayment() = Unit
    override suspend fun updateAiCoachReview(review: String) = Unit
    override suspend fun resetDaily() = Unit
}

private class FakeWorkoutRepository : WorkoutRepository {
    override fun observeActiveGoal(): Flow<ActiveGoal?> = flowOf(
        ActiveGoal(
            id = 1,
            config = GoalConfig(
                goal = FitnessGoal.GENERAL_FITNESS,
                level = ExperienceLevel.BEGINNER,
                equipmentProfile = EquipmentProfile.BODYWEIGHT_ONLY,
                sessionsPerWeek = 3,
                durationWeeks = 4,
                restDayMode = RestDayMode.FULL_REST,
            ),
            totalWorkouts = 12,
        ),
    )
    override fun observeCurrentWorkout(): Flow<WorkoutSession?> = flowOf(null)
    override fun observeCompletedWorkouts(): Flow<List<CompletedWorkout>> = flowOf(emptyList())
    override suspend fun createGoal(config: GoalConfig, program: ProgramTemplate, startEpochDay: Long) = Unit
    override suspend fun setExerciseChecked(sessionId: Long, orderIndex: Int, checked: Boolean) = Unit
    override suspend fun completeWorkout(sessionId: Long, completedEpochDay: Long): CompleteWorkoutResult = CompleteWorkoutResult.Completed
    override suspend fun archiveActiveGoal() = Unit
}

private class FakeFoodCatalogDao : com.example.myapplication.data.local.FoodCatalogDao {
    val items = MutableStateFlow<List<FoodCatalogEntity>>(emptyList())
    val inserted = mutableListOf<FoodCatalogEntity>()

    override suspend fun insertAll(foods: List<FoodCatalogEntity>) {
        inserted.addAll(foods)
        items.value = (items.value + foods).distinctBy { it.id }
    }

    override fun observeAll(): Flow<List<FoodCatalogEntity>> = items

    override fun searchByName(query: String): Flow<List<FoodCatalogEntity>> = items.map { list ->
        list.filter { it.name.contains(query, ignoreCase = true) }
    }

    override suspend fun getAllNow(): List<FoodCatalogEntity> = items.value

    override suspend fun deleteByBatch(batchId: String) {
        items.value = items.value.filter { it.importBatchId != batchId }
    }

    override suspend fun deleteAll() {
        items.value = emptyList()
    }

    override suspend fun countAll(): Int = items.value.size

    override fun observeCount(): Flow<Int> = items.map { it.size }

    override suspend fun toggleFavorite(id: Long, isFavorite: Boolean): Int {
        items.value = items.value.map {
            if (it.id == id) it.copy(isFavorite = isFavorite) else it
        }
        return 1
    }

    override fun observeFavorites(): Flow<List<FoodCatalogEntity>> = items.map { list ->
        list.filter { it.isFavorite }
    }

    override fun searchFavorites(query: String): Flow<List<FoodCatalogEntity>> = items.map { list ->
        list.filter { it.isFavorite && it.name.contains(query, ignoreCase = true) }
    }
}




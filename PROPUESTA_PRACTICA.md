# 📚 Pantalla de Práctica - Propuesta de Diseño

## 🎯 Objetivo

Crear una experiencia educativa donde los usuarios puedan practicar lógica proposicional y recibir feedback inmediato sobre su comprensión.

---

## 💡 Propuestas de Implementación

### **Opción 1: Quiz de Clasificación (Más Simple) ⭐ RECOMENDADA**

#### Flujo:

1. Sistema genera una expresión lógica aleatoria
2. Usuario ve la expresión (ej: `A ∧ ¬A`)
3. Usuario debe clasificarla sin calcularla:
   - 🟢 Tautología
   - 🔴 Contradicción
   - 🟡 Contingencia
4. Usuario puede:
   - **Responder directamente** (más puntos)
   - **Ver pista** (menos puntos)
   - **Ver tabla completa** (sin puntos, solo aprendizaje)
5. Feedback inmediato:
   - ✅ Correcto: +10 puntos, explicación breve
   - ❌ Incorrecto: 0 puntos, explicación detallada + mostrar tabla

#### Niveles de Dificultad:

```dart
// Básico (2-3 variables, operadores simples)
"A ∨ ¬A"           // Tautología obvia
"A ∧ ¬A"           // Contradicción obvia
"A ∨ B"            // Contingencia simple

// Intermedio (2-3 variables, más operadores)
"(A ⇒ B) ∨ (B ⇒ A)"
"(A ∧ B) ⇒ A"
"A ⇔ (A ∨ B)"

// Avanzado (3-4 variables, operadores complejos)
"((A ⇒ B) ∧ (B ⇒ C)) ⇒ (A ⇒ C)"
"(A ⊻ B) ⇔ ¬(A ⇔ B)"
"((A ∨ B) ∧ ¬A) ⇒ B"
```

#### UI Mockup:

```
┌────────────────────────────────┐
│  🎯 Práctica - Nivel: Básico   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                │
│  Pregunta 5 de 10              │
│  Racha: 3 🔥                   │
│  Puntos: 40 ⭐                 │
│                                │
│  ┌──────────────────────────┐  │
│  │                          │  │
│  │      A ∧ ¬A              │  │
│  │                          │  │
│  └──────────────────────────┘  │
│                                │
│  ¿Qué tipo de expresión es?    │
│                                │
│  [ Tautología ✅ ]            │
│  [ Contradicción ❌ ]         │
│  [ Contingencia ⚠️ ]          │
│                                │
│  ─────────────────────────────│
│  💡 Ver Pista  |  📊 Ver Tabla│
│                                │
└────────────────────────────────┘
```

#### Sistema de Puntuación:

- Respuesta correcta sin ayuda: **+10 puntos**
- Respuesta correcta con pista: **+5 puntos**
- Respuesta correcta después de ver tabla: **+2 puntos**
- Respuesta incorrecta: **0 puntos**
- Racha de 3 correctas: **+5 puntos bonus**
- Racha de 5 correctas: **+10 puntos bonus**

---

### **Opción 2: Completar Tabla (Intermedio)**

#### Flujo:

1. Mostrar expresión y tabla parcialmente completa
2. Usuario debe rellenar celdas vacías
3. Verificar cada celda al enviar
4. Feedback visual: verde (correcto) / rojo (incorrecto)

#### UI Ejemplo:

```
Expresión: A ∧ B

┌───┬───┬───────┐
│ A │ B │ A ∧ B │
├───┼───┼───────┤
│ V │ V │  ???  │ ← Usuario debe completar
│ V │ F │  ???  │
│ F │ V │  ???  │
│ F │ F │  ???  │
└───┴───┴───────┘

[ Verificar Respuestas ]
```

#### Variantes:

- **Modo Fácil**: Solo columna final
- **Modo Medio**: Columnas intermedias también
- **Modo Difícil**: Todas las columnas

---

### **Opción 3: Desafío por Tiempo (Avanzado)**

#### Flujo:

1. 10 expresiones en 2 minutos
2. Responder lo más rápido posible
3. Puntuación basada en tiempo y precisión
4. Tabla de clasificación (local)

#### Fórmula de Puntos:

```dart
puntos = (correctas * 100) - (tiempo_segundos * 2) + bonus_racha
```

---

### **Opción 4: Modo Aprendizaje Guiado (Educativo)**

#### Flujo:

1. Mostrar expresión compleja
2. Descomponerla paso a paso
3. En cada paso, preguntar: "¿Cuál es el resultado?"
4. Usuario responde V o F
5. Feedback inmediato con explicación

#### Ejemplo:

```
Expresión: (A ∧ B) ⇒ C
Para A=V, B=V, C=F

Paso 1: Evaluar A ∧ B
        V ∧ V = ???

        [ V ]  [ F ]

Paso 2: Evaluar (V) ⇒ C
        V ⇒ F = ???

        [ V ]  [ F ]
```

---

## 🏗️ Arquitectura Propuesta (Opción 1)

### Modelos de Datos

```dart
// lib/model/practice_exercise.dart
class PracticeExercise {
  final String expression;
  final TruthTableType correctAnswer;
  final DifficultyLevel difficulty;
  final String? hint;
  final String? explanation;

  PracticeExercise({
    required this.expression,
    required this.correctAnswer,
    required this.difficulty,
    this.hint,
    this.explanation,
  });
}

enum DifficultyLevel { basic, intermediate, advanced }

// lib/model/practice_session.dart
class PracticeSession {
  final DateTime startTime;
  int currentQuestion;
  int correctAnswers;
  int totalQuestions;
  int points;
  int streak;
  List<PracticeResult> results;

  double get accuracy => correctAnswers / totalQuestions;
  Duration get elapsedTime => DateTime.now().difference(startTime);
}

class PracticeResult {
  final PracticeExercise exercise;
  final TruthTableType? userAnswer;
  final bool isCorrect;
  final bool usedHint;
  final bool viewedTable;
  final int pointsEarned;
}
```

### Generador de Ejercicios

```dart
// lib/utils/exercise_generator.dart
class ExerciseGenerator {
  static final Random _random = Random();

  // Banco de expresiones por dificultad
  static final Map<DifficultyLevel, List<ExerciseTemplate>> _exercises = {
    DifficultyLevel.basic: [
      ExerciseTemplate(
        pattern: 'A ∨ ¬A',
        type: TruthTableType.tautology,
        hint: 'Una proposición O su negación siempre es verdadera',
      ),
      ExerciseTemplate(
        pattern: 'A ∧ ¬A',
        type: TruthTableType.contradiction,
        hint: 'Una proposición Y su negación siempre es falsa',
      ),
      // ... más ejercicios
    ],
    // ...
  };

  static PracticeExercise generate(DifficultyLevel level) {
    final templates = _exercises[level]!;
    final template = templates[_random.nextInt(templates.length)];

    // Generar variante con variables aleatorias
    final vars = _generateRandomVariables(template.variableCount);
    final expression = _replaceVariables(template.pattern, vars);

    return PracticeExercise(
      expression: expression,
      correctAnswer: template.type,
      difficulty: level,
      hint: template.hint,
      explanation: template.explanation,
    );
  }

  static List<String> _generateRandomVariables(int count) {
    final allVars = ['p', 'q', 'r', 's', 'a', 'b', 'c'];
    allVars.shuffle();
    return allVars.take(count).toList();
  }
}
```

### Pantalla Principal

```dart
// lib/screens/practice_screen.dart
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late PracticeSession _session;
  late PracticeExercise _currentExercise;
  DifficultyLevel _selectedLevel = DifficultyLevel.basic;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _startNewSession();
  }

  void _startNewSession() {
    setState(() {
      _session = PracticeSession(
        startTime: DateTime.now(),
        currentQuestion: 0,
        correctAnswers: 0,
        totalQuestions: 10,
        points: 0,
        streak: 0,
        results: [],
      );
      _loadNextExercise();
    });
  }

  void _loadNextExercise() {
    setState(() {
      _currentExercise = ExerciseGenerator.generate(_selectedLevel);
      _showHint = false;
    });
  }

  void _submitAnswer(TruthTableType answer) {
    // Calcular la respuesta correcta usando TruthTable
    final truthTable = TruthTable(
      _currentExercise.expression,
      'es',
      TruthFormat.vf,
    );
    truthTable.makeAll();

    final isCorrect = answer == truthTable.tipo;

    // Actualizar sesión
    setState(() {
      _session.currentQuestion++;
      if (isCorrect) {
        _session.correctAnswers++;
        _session.streak++;

        // Calcular puntos
        int points = 10;
        if (_showHint) points = 5;
        if (_session.streak >= 3) points += 5;
        if (_session.streak >= 5) points += 10;

        _session.points += points;
      } else {
        _session.streak = 0;
      }

      _session.results.add(PracticeResult(
        exercise: _currentExercise,
        userAnswer: answer,
        isCorrect: isCorrect,
        usedHint: _showHint,
        viewedTable: false,
        pointsEarned: isCorrect ? points : 0,
      ));
    });

    // Mostrar feedback
    _showFeedbackDialog(isCorrect, truthTable);
  }

  void _showFeedbackDialog(bool isCorrect, TruthTable truthTable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? '✅ ¡Correcto!' : '❌ Incorrecto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCorrect)
              Text('¡Excelente! Ganaste ${_session.points} puntos'),
            if (!isCorrect) ...[
              Text('La respuesta correcta es: ${_getTypeName(truthTable.tipo)}'),
              SizedBox(height: 8),
              Text(_currentExercise.explanation ?? 'Revisa la tabla de verdad'),
            ],
          ],
        ),
        actions: [
          if (!isCorrect)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showFullTable(truthTable);
              },
              child: Text('Ver Tabla'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_session.currentQuestion < _session.totalQuestions) {
                _loadNextExercise();
              } else {
                _showResults();
              }
            },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎯 Práctica'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de progreso
            LinearProgressIndicator(
              value: _session.currentQuestion / _session.totalQuestions,
            ),
            SizedBox(height: 16),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.question_mark,
                  label: 'Pregunta',
                  value: '${_session.currentQuestion + 1}/${_session.totalQuestions}',
                ),
                _StatCard(
                  icon: Icons.star,
                  label: 'Puntos',
                  value: '${_session.points}',
                ),
                _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Racha',
                  value: '${_session.streak}',
                ),
              ],
            ),

            SizedBox(height: 24),

            // Expresión
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  _currentExercise.expression,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            if (_showHint) ...[
              SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(_currentExercise.hint ?? 'Analiza cuidadosamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 32),

            // Opciones de respuesta
            Column(
              children: [
                _AnswerButton(
                  label: 'Tautología ✅',
                  subtitle: 'Siempre verdadera',
                  color: Colors.green,
                  onTap: () => _submitAnswer(TruthTableType.tautology),
                ),
                SizedBox(height: 12),
                _AnswerButton(
                  label: 'Contradicción ❌',
                  subtitle: 'Siempre falsa',
                  color: Colors.red,
                  onTap: () => _submitAnswer(TruthTableType.contradiction),
                ),
                SizedBox(height: 12),
                _AnswerButton(
                  label: 'Contingencia ⚠️',
                  subtitle: 'Depende de los valores',
                  color: Colors.orange,
                  onTap: () => _submitAnswer(TruthTableType.contingency),
                ),
              ],
            ),

            Spacer(),

            // Ayudas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text('Ver Pista'),
                  onPressed: _showHint ? null : () => setState(() => _showHint = true),
                ),
                TextButton.icon(
                  icon: Icon(Icons.table_chart),
                  label: Text('Ver Tabla'),
                  onPressed: _showTableForLearning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 Características Adicionales

### 1. **Estadísticas Persistentes**

```dart
// SQLite
CREATE TABLE practice_stats (
  id INTEGER PRIMARY KEY,
  date DATE,
  total_questions INTEGER,
  correct_answers INTEGER,
  total_points INTEGER,
  best_streak INTEGER,
  difficulty TEXT,
  avg_time_per_question REAL
);
```

### 2. **Logros/Achievements**

- 🏆 Primera Victoria: Responde correctamente
- 🔥 Racha de 5
- 💯 Precisión del 100%
- 📚 Maestro: 100 ejercicios completados
- ⚡ Veloz: Responde en menos de 5 segundos

### 3. **Modo Desafío Diario**

- Un ejercicio especial cada día
- Puntos dobles
- Tabla de clasificación semanal

---

## 🎨 Pantalla de Resultados

```
┌────────────────────────────────┐
│  🎉 ¡Sesión Completada!        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                │
│  Puntuación Final              │
│  ⭐ 85 puntos                  │
│                                │
│  📊 Estadísticas               │
│  ✅ 8/10 correctas (80%)      │
│  🔥 Mejor racha: 5             │
│  ⏱️ Tiempo: 3:24              │
│                                │
│  🎯 Desglose                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  ✅ Pregunta 1 - Tautología    │
│  ✅ Pregunta 2 - Contingencia  │
│  ❌ Pregunta 3 - Contradicción │
│  ...                           │
│                                │
│  [ Revisar Errores ]           │
│  [ Nueva Sesión ]              │
│  [ Ver Ranking ]               │
│                                │
└────────────────────────────────┘
```

---

## 🚀 Roadmap de Implementación

### Fase 1: MVP (1-2 semanas)

- ✅ Modelo de datos básico
- ✅ Generador de ejercicios (10-15 por nivel)
- ✅ Pantalla de práctica
- ✅ Sistema de puntuación
- ✅ Feedback inmediato

### Fase 2: Mejoras (1 semana)

- ✅ Persistencia de estadísticas
- ✅ Pantalla de resultados
- ✅ Más ejercicios (50+ total)
- ✅ Selector de dificultad

### Fase 3: Gamificación (1 semana)

- ✅ Sistema de logros
- ✅ Racha histórica
- ✅ Gráficas de progreso
- ✅ Modo desafío diario

---

## 💰 Monetización (Opcional)

### Versión Gratuita:

- 5 ejercicios por día
- Solo nivel básico
- Con anuncios entre sesiones

### Versión Pro:

- Ejercicios ilimitados
- Todos los niveles
- Sin anuncios
- Estadísticas avanzadas
- Modo offline con sincronización

---

## 🧪 Preguntas para Definir

1. **¿Qué nivel de dificultad prefieres empezar?**
   - Solo básico inicialmente
   - Los tres niveles desde el inicio

2. **¿Sistema de puntuación importante?**
   - Sí, con ranking/leaderboard
   - No, solo enfoque educativo

3. **¿Modo de práctica?**
   - Opción 1: Quiz de clasificación ⭐
   - Opción 2: Completar tabla
   - Opción 3: Por tiempo
   - Opción 4: Aprendizaje guiado
   - Combinación de varias

4. **¿Integrar con backend?**
   - Sí, para compartir ejercicios
   - No, todo local

5. **¿Añadir al drawer o como nueva ruta?**
   - En drawer principal
   - En pestaña separada
   - Botón flotante en home

---

## 📝 Mi Recomendación

**Empezar con Opción 1 (Quiz de Clasificación)** porque:

✅ Simple de implementar  
✅ Efectiva educativamente  
✅ Engagement rápido (feedback inmediato)  
✅ Escalable (fácil agregar más modos después)  
✅ No requiere backend (todo local)  
✅ Buen equilibrio diversión/aprendizaje

Luego, basado en feedback de usuarios, agregar:

- Modo completar tabla (Opción 2)
- Modo por tiempo (Opción 3)
- Tutorial interactivo (Opción 4)

---

¿Qué te parece? ¿Con cuál opción quieres empezar o prefieres una combinación? Puedo ayudarte a implementar la que elijas paso a paso.

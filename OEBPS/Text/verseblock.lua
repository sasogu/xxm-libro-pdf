function Div(el)
    if el.classes:includes('verse2') then
      if FORMAT:match('latex') then
        return {
          pandoc.RawBlock('latex', '\\begin{center}'),
          el,
          pandoc.RawBlock('latex', '\\end{center}')
        }
      end
    end
  end

  function Div(el)
    if el.classes:includes('verse') then
        if FORMAT:match('latex') then
            local content = pandoc.write(pandoc.Pandoc(el.content), "latex")
            return {
                pandoc.RawBlock('latex', '\\clearpage'),
                pandoc.RawBlock('latex', '\\vspace*{\\fill}'),
                pandoc.RawBlock('latex', '\\noindent\\begin{minipage}{\\textwidth}\\centering'),
                pandoc.RawBlock('latex', '\\Large'), -- << Añadido: tamaño de fuente
                pandoc.RawBlock('latex', '\\setlength{\\parskip}{1em}'), -- Espacio entre párrafos
                pandoc.RawBlock('latex', content),
                pandoc.RawBlock('latex', '\\end{minipage}'),
                pandoc.RawBlock('latex', '\\vspace*{\\fill}'),
                pandoc.RawBlock('latex', '\\clearpage')
            }
        end
    end
end


  
  function Header(el)
    if el.level == 1 and FORMAT:match('latex') then
      -- Salto de página + centrar encabezados h1
      return {
        pandoc.RawBlock('latex', '\\clearpage'),
        pandoc.RawBlock('latex', '\\begin{center}\\Huge\\textbf{' .. pandoc.utils.stringify(el.content) .. '}\\end{center}')
      }
    end
  end

-- Tabla de notas locales
local notes = {
    ["nota1"] = "Esta expresión, utilizada por Dōgen Zenji, se traduce habitualmente como 'abandono de cuerpo y mente'. Señala el momento en el que, a través de zazen, se sueltan espontáneamente las fijaciones que crean la ilusión de un yo separado.",
    ["nota2"] = "Dōgen Zenji (1200–1253), fundador de la escuela Sōtō Zen en Japón, fue uno de los grandes maestros de la transmisión zen. Sus enseñanzas, recogidas principalmente en el Shōbōgenzō, nos guían hacia la realización directa de la realidad tal cual es.",
    ["nota3"] = "Según la RAE.",
    ["nota4"] = "El Tao Te Ching, atribuido tradicionalmente a Lao-Tsé, es un texto clásico del pensamiento taoísta. Inspiró profundamente la espiritualidad china y, a su vez, influenció el surgimiento del budismo Chan, especialmente en su visión de la espontaneidad y la no-dualidad.",
    ["nota5"] = "Mahāyāna, el 'Gran Vehículo', es una de las principales corrientes del budismo. Pone el énfasis en la compasión universal y en la aspiración de alcanzar el despertar para el beneficio de todos los seres.",
    ["nota6"] = "Maha Prajña Paramita Hridaya Sutra, en sánscrito. Maka Hannya Haramita Shingyo, en japonés",
    ["nota7"] = "Śūnyatā o 'vacuidad' es un término central en el budismo. No indica vacío como carencia, sino la ausencia de esencia fija en todos los fenómenos. Nada existe por sí mismo: todo surge en interdependencia con todo lo demás.",
    ["nota8"] = "Un día en que Dogen estaba sentado en Zazen, su vecino se durmió. El maestro Nyojo golpeo con fuerza al discípulo y con voz fuerte gritó: “¡Zazen es abandonar cuerpo y mente!: ¿Por qué duermes?”. Al oír estas palabras, Dogen experimento el gran despertar. Después Dogen fue a ver a Nyojo y le dijo: “— He abandonado cuerpo y mente - shin jin datsu raku”. Nyojo le contestó: “-¡Abandona ahora la noción de haber abandonado cuerpo y mente!” Dogen se postró entonces respetuosamente ante Nyojo y este añadió: “Cuerpo y mente han sido abandonados - datsu raku shin jin” ",
    ["nota9"] = "Mushotoku es una expresión zen (無所得) que podría traducirse literalmente como ‘no provecho’, ‘no obtención’, o ‘nada que obtener’, lo que viene a significar ‘hacer algo sin esperar ningún beneficio personal’.",
    ["nota10"] = "Estado de profunda concentración meditativa en el cual la mente se vuelve completamente unificada y tranquila, dejando de estar dispersa o distraída. En este estado, el sentido de separación entre el sujeto y el objeto desaparece, y el practicante experimenta una absorción completa en la experiencia presente, trascendiendo la dualidad.",
    ["nota12"] = "La identificación con un yo autónomo e independiente se considera una ilusión en el budismo, ya que, según la doctrina del anatta (no-yo), no existe un “yo” permanente e inmutable. Liberarse de esta identificación es esencial para alcanzar el despertar.",
    ["nota13"] = "La Visión Correcta (Sammā-Diṭṭhi) es el primer elemento del Noble Óctuple Sendero en el budismo, que se refiere a la comprensión clara de la realidad tal como es. Implica ver las cosas con sabiduría, reconociendo la naturaleza de las Cuatro Nobles Verdades y el origen del sufrimiento. Es fundamental para desarrollar un enfoque justo y equilibrado hacia la vida, liberándonos de la ignorancia y el apego que causan el sufrimiento.",
    ["nota14"] = "El Sutra del Corazón, o Maka Hannya Haramita Shingyo, es uno de los textos más recitados del budismo Mahāyāna. Resume la enseñanza de la vacuidad, mostrando que forma y vacío son inseparables.",
    ["nota15"] = "Samsara representa el ciclo de nacimiento, muerte y renacimiento condicionado por la ignorancia y el apego. Es el campo de existencia marcado por el sufrimiento, del que los seres pueden liberarse a través del despertar.",
    ["nota16"] = "División de un concepto o una materia teórica en dos aspectos, especialmente cuando son opuestos o están muy diferenciados entre sí. ",
    ["nota17"] = "El Fukanzazengi es uno de los textos esenciales de Dōgen Zenji, donde expone las instrucciones básicas para la práctica de zazen. Nos invita a sentarnos de manera natural, sin buscar alcanzar estados especiales, dejando caer todo juicio.",
    ["nota18"] = "En el budismo, se reconocen tanto la verdad relativa como la verdad absoluta. La verdad relativa reconoce la aparente dualidad entre el sujeto y el objeto en nuestra experiencia cotidiana, mientras que la verdad absoluta revela la vacuidad y la unidad fundamental de todos los fenómenos. Ambas perspectivas son complementarias y nos permiten comprender la realidad de manera más completa. Al reconocer la interconexión y la unidad subyacente del sujeto y el objeto, podemos trascender las limitaciones de la dualidad y experimentar la realidad en su plenitud.",
    ["nota19"] = "Sanran describe el estado de mente agitada, dispersa en pensamientos y deseos. Kontin es su opuesto: la mente embotada, sumida en la somnolencia o la apatía. En la práctica de zazen buscamos un equilibrio entre ambos extremos: alerta y serenidad.",
    ["nota20"] = "Las paramitas son cualidades o prácticas de perfección que el bodhisattva cultiva en el camino hacia el despertar. Entre ellas se encuentran la generosidad, la paciencia, la disciplina, la energía, la concentración y la sabiduría.",
    ["nota21"] = "Tathatā, a veces traducido como 'talidad', se refiere a la realidad tal como es, más allá de toda interpretación o conceptualización. Es ver las cosas en su plenitud, sin añadir ni quitar nada.",
    ["nota11"] = "Blaise Pascal (1623-1662), filósofo y matemático francés, reflexionó sobre la naturaleza humana y la necesidad de detenerse para contemplar la vida en profundidad. Una de sus intuiciones más célebres fue que muchos de nuestros problemas provienen de no saber estar en silencio y en soledad."
    
    
    
    
  }

-- Función para procesar enlaces y convertirlos en notas al pie
function Link(el)
  if el.target:match("^#nota") then
      -- Extraer el identificador de la nota (por ejemplo, "nota1")
      local note_id = el.target:match("#(nota%d+)")
      -- Buscar el contenido de la nota en la tabla
      local note_content = notes[note_id] or "Nota no encontrada."
      -- Generar una nota al pie en LaTeX
      return pandoc.RawInline('latex', '\\footnote{' .. note_content .. '}')
  end
end

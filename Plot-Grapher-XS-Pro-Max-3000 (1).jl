#= -------------------PLOT GRAPHER XS PRO MAX 3000-------------------
OBOWIĄZKOWO:
    1. Podajemy wzór funkcji zależnej od x, używając klawiatury lub przycisków (zachowując dokładną składnię).
    2. Ustalamy zakresy osi lub zaznaczamy domyślne (uwaga: w przypadku wybouru zakresów, musimy podać zarówno zakres osi Ox, jak i osi Oy; trzeba również pamiętać, by dla logarytmu jako dziedziny nie podawać liczb ujemnych).
    3. Ustalamy dokładność(ilość punktów z dziedziny, w których obliczamy wartości funkcji).
    OPCJONALNIE:
        4. Wybieramy aproksymację szeregiem Taylora (kolor niebieski na wykresie) - wtedy trzeba też uzupełnić okienka dotyczące punktu bazowego i dokładności n.
            4.1. Można dodatkowo stworzyć animację GIF szeregu Taylora.
        5. Wybieramy, czy program ma rysować pochodne (kolor zielony) na wykresie - jeśli tak, podajemy rząd w okienku poniżej.
        6. Wybieramy, czy program ma tworzyć legendę wykresu.
        7. Wybieramy, czy program ma rysować siatkę.
Gdy zaznaczymy i ustawimy nasze preferencje:
    8. Generujemy funkcję przyciskiem "GENERUJ".
    9. Przyciskiem "RYSUJ" tworzymy okno z wykresem oraz (gdy zaznaczona animacja) okno z GIF-em (GIF zapisuje się również w osobnym pliku).
UWAGA: Przypadek, gdy program zwróci pusty wykres, będzie oznaczać, że podaliśmy błędne dane.
  -------------------PLOT GRAPHER XS PRO MAX 3000------------------- =#

# Imporujemy potrzebne moduły:

using Gtk               # •do GUI
using Winston           # •do wykresów
using SymPy             # •do obliczania pochodnych
using TaylorSeries      # •do rozwinięcia wzorem Taylora
using Plots             # •do wykresu w animacji
using LaTeXStrings      # •do kosemtycznych walorów animacji

#--------Część 1. GUI--------

win = GtkWindow("Plot Grapher XS Pro Max 3000")     # Inicjalizujemy nowe okno.
g = GtkGrid()                                       # Deklatujemy sposób rozmieszczenia elementów GUI (w siatce)

# Ustalamy pozycję, wielkość i rodzaj wszystkich przycisków.
# Dla pól wprowadzania tekstów ustalamy wartość początkową jako opis akcji użytkownika.

g[1:6, 1] = ent = GtkEntry()
set_gtk_property!(ent, :text, "Podaj wzór funkcji zależnej od x")

g[1:3, 7] = check_taylor = GtkCheckButton("Aproksymacja szeregiem Taylora")

g[1:3, 8] = ent_base_point = GtkEntry()
set_gtk_property!(ent_base_point, :text, "Określ punkt bazowy x₀")

g[1:3, 9] = ent_precision = GtkEntry()
set_gtk_property!(ent_precision, :text, "Określ dokładność n∈N")

g[1:3, 10] = check_anim = GtkCheckButton("Stwórz animację szeregu Taylora")

g[1:3, 11] = check_diff = GtkCheckButton("Rysuj pochodne")

g[1:3, 12] = ent_n_diff = GtkEntry()
set_gtk_property!(ent_n_diff, :text, "Podaj rząd pochodnej n∈N")

g[1:3, 13] = check_legend = GtkCheckButton("Legenda")

g[1:3, 14] = check_grid = GtkCheckButton("Siatka")

g[4:6, 7] = check_default_lims = GtkCheckButton("Domyślne zakresy osi")

g[4:6, 8] = ent_xlims = GtkEntry()
set_gtk_property!(ent_xlims, :text, "Zakres osi Ox (np. 1 2)")

g[4:6, 9] = ent_ylims = GtkEntry()
set_gtk_property!(ent_ylims, :text, "Zakres osi Oy (np. 1 2)")

g[4:6, 10] = ent_title = GtkEntry()
set_gtk_property!(ent_title, :text, "Tytuł wykresu")

g[4:6, 11] = ent_x_label = GtkEntry()
set_gtk_property!(ent_x_label, :text, "Tytuł osi Ox")

g[4:6, 12] = ent_y_label = GtkEntry()
set_gtk_property!(ent_y_label, :text, "Tytuł osi Oy")

g[4:6, 13] = check_precision = GtkCheckButton("Domyślna dokładność (2000 punktów)")

g[4:6, 14] = ent_nr_points = GtkEntry()
set_gtk_property!(ent_nr_points, :text, "Ilość punktów / dokładność (np. 5000)")

# Poniżej definiujemy przyciski kalkulatora:

g[1, 2] = btn_1 = GtkButton("1")
g[2, 2] = btn_2 = GtkButton("2")
g[3, 2] = btn_3 = GtkButton("3")
g[4, 2] = btn_4 = GtkButton("4")
g[5, 2] = btn_5 = GtkButton("5")
g[6, 2] = btn_6 = GtkButton("6")
g[1, 3] = btn_7 = GtkButton("7")
g[2, 3] = btn_8 = GtkButton("8")
g[3, 3] = btn_9 = GtkButton("9")
g[4, 3] = btn_0 = GtkButton("0")
g[5, 3] = btn_left = GtkButton("(")
g[6, 3] = btn_right = GtkButton(")")
g[1, 4] = btn_plus = GtkButton("+")
g[2, 4] = btn_min = GtkButton("-")
g[3, 4] = btn_mul = GtkButton("*")
g[4, 4] = btn_div = GtkButton("/")
g[5, 4] = btn_pow = GtkButton("^")
g[6, 4] = btn_x = GtkButton("(x)")
g[1, 5] = btn_sin = GtkButton("sin")
g[2, 5] = btn_cos = GtkButton("cos")
g[3, 5] = btn_tan = GtkButton("tan")
g[4, 5] = btn_log = GtkButton("log")
g[5, 5] = btn_exp = GtkButton("exp")
g[6, 5] = btn_sqrt = GtkButton("sqrt")
g[1, 6] = btn_dot = GtkButton(".")
g[2, 6] = btn_del = GtkButton("WYCZYŚĆ")
g[3:4, 6] = btn_generate = GtkButton("GENERUJ")
g[5:6, 6] = btn_draw = GtkButton("RYSUJ")

# Ustawiamy odstępy, marginesy i inne kosmetyczne detale.

set_gtk_property!(g, :column_homogeneous, true)
set_gtk_property!(g, :row_homogeneous, true)
set_gtk_property!(g, :column_spacing, 5)
set_gtk_property!(g, :row_spacing, 5)
set_gtk_property!(g, :margin, 10)

push!(win, g)
showall(win)

#--------Część 2. OBLICZENIA I MECHANIZMY--------

"""
    set_prop(w)
    w - przycisk GUI
    Przypisuje przyciskowi w użyteczność. Jego naciśnięcie sprawi,
    że do wartości w polu ent zostanie dopisana wartość z etykiety przycisku w.
    W przypadku, gdy wartość pola ent będzie wartością początkową,
    wartośc etykiety przycisku w zostanie nadpisana do wartości ent (usuwając jego wartość początkową).
"""
function set_prop(w)
    new = get_gtk_property(w, :label, String)       # Pobieramy wartości pola etykiety pryciku w
    old = get_gtk_property(ent, :text, String)      # oraz wartość pola ent.
    if old == "Podaj wzór funkcji zależnej od x"    # Jeśli wartość ent == wartość początkowa,
        set_gtk_property!(ent, :text, new)          # -> nadpisz.
    else                                            # W przciwnym przypadku
        set_gtk_property!(ent, :text, old * new)    # -> dopisz.
    end
end

buttons = (     # Lista przycisków kalkulatora.
    btn_1,
    btn_2,
    btn_3,
    btn_4,
    btn_5,
    btn_6,
    btn_7,
    btn_8,
    btn_9,
    btn_0,
    btn_left,
    btn_right,
    btn_plus,
    btn_min,
    btn_mul,
    btn_div,
    btn_pow,
    btn_sqrt,
    btn_sin,
    btn_cos,
    btn_tan,
    btn_log,
    btn_exp,
    btn_x,
    btn_dot,
)

for b in buttons                                # Każdemu przyciskowi kalkulatora
    signal_connect(set_prop, b, "clicked")      # przypisujemy funkcjonalność.
end

# Poniższa funkcja powstała jako alternatywne rozwiązanie problemu, który zaistniał
# podczas prac nad programem. Po szkicowaniu wykresu program mimo zmiany danych
# szkicował wykres poprzedni. Potrzebował jednego 'cyklu', aby zamienić starą funkcję na nową.
# W konsekwencji przycisk "GENERUJ" nie jest koniecznością, był jednak jedynym rozwiąznaiem
# które pomogło zoptymalizować działanie programu.
"""
    generate(w)
    w - przycisk w GUI
    (funkcja pomocnicza) Generuje funkcję na podstawie wartości pola ent,
    konwertując jej wzór z typu string.
"""
function generate(w)
    funkcja = "f(x)=" * get_gtk_property(ent, :text, String)    # Pobieramy wartość z pola ent.
    eval(Meta.parse(funkcja))                                   # Konwertujemy typ string na function.
end

signal_connect(generate, btn_generate, "clicked")   # Przypisujemy funkcjonalność odpowiedniemu przyciskowi.

"""
    clear(w)
    w - przycisk w GUI
    Czyści pole ent, przywracając mu wartość początkową.
"""
function clear(w)
    set_gtk_property!(ent, :text, "Podaj wzór funkcji zależnej od x")
end

signal_connect(clear, btn_del, "clicked")   # Przypisujemy funkcjonalnośc odpowiedniemu przyciskowi.

"""
    Taylor(f, x, n)
    f - funkcja, którą chcemy przybliżyć szeregiem Taylora
    x - punkt bazowy
    n - (∈ N) dokładność
    Tworzy gif obrazujący przybliżanie funkcji f szeregiem Taylora w punkcie
    x z dokładnością 1, 2, ..., n.
"""
function Taylor(f::Function, x::Number, n::Int)
    # Najpierw definiujemy wykres funkcji f, jako zaresy i podpisy ustalamy te podane przez użytkownika.
    p = Plots.plot(
        trim(f),
        xs,
        label = latexstring("\$f(x)=$(get_gtk_property(ent, :text, String))\$"),
        legend = :outerright,
        title = get_gtk_property(ent_title, :text, String),
        xlabel = get_gtk_property(ent_x_label, :text, String),
        ylabel = get_gtk_property(ent_y_label, :text, String),
        ylims = ys,
        size = (880, 780)
    )

    anim = Animation()          # Rozpoczynamy tworzenie animacji. W tym celu inicjalizujemy funkcję Animation().
    frame(anim)                 # I jako pierwszą klatkę dodajemy swtorzony wcześniej wykres.
    for i = 1:n                                 # Tworzymy n kolejnych wykresów szeregu Taylora.
        s = taylor_expand(f, x, order = i)      # Każdy z coraz większą dokładnością.
        update!(s, -x)
        Plots.plot!(                            # Kolejne wykresy nakładamy na siebie.
            xs,
            evaluate.(s, xs),
            label = latexstring("\$n = $i\$"),
            title = get_gtk_property(ent_title, :text, String),
            xlabel = get_gtk_property(ent_x_label, :text, String),
            ylabel = get_gtk_property(ent_y_label, :text, String),
            ylims = ys
        )
        frame(anim)                                 # I dodajemy tak kolejne n wykresów, klatka po klatce.
    end
    gif(anim, "Taylor-expansion.gif", fps = 1)      # Ostatecznie towrzymy animację, zapisując ją jako .gif.
end

# Jak przekonaliśmy się na początku semestru, Julia nie radzi sobie
# z niektórymi funkcjami nieciągłymi. W dbałości o szczegóły
# rozwiązaliśmy ten problem i stworzyliśmy poniższą funkcję.
"""
    trim(f)
    f - funkcja
    Poprawia wykresy funkcji nieciągłych,
    tak aby w miejscach asymptotycznych przyjmowały one wartości NaN.
"""
trim(f) = x -> abs(f(x)) > 2*max(abs(ys[1]),abs(ys[2])) ? NaN : f(x)
# Jeśli wartości funkcji będą wykraczały poza limity osi Oy, które narzucił użytkownik,
# Funkcja dla tych punktów, zwróci wartość nieokreśloną NaN.
# W przeciwnym wypadku obliczamy wartości zgodnie ze wzorem.
# (jeśli wprowadzana funkcja dalej jest "brzydka" trzeba zwiekszyć precyzje)
"""
    on_button_clicked(w)
    w - przycisk w GUI
    Rysuje odpowiedni wykres, bazując na ustalonych przez użytkownika danych.
"""
function on_button_clicked(w)

    # Ustawiamy tytuł i podpisy wykresu, odczytując wartości z odpowiednich pól ent.
    p_title = get_gtk_property(ent_title, :text, String)
    p_xlbl = get_gtk_property(ent_x_label, :text, String)
    p_ylbl = get_gtk_property(ent_y_label, :text, String)

    # (*) W niektórych polach pozostawiamy użytkownikowi wybór.
    # Jeśli wybierze wartość doimyślną, funkcja skorzysta z narzuconych przez nas danych.
    # W przeciwnym wypadku bezpośrednio odczyta dane użytkownika.
    if get_gtk_property(check_precision, :active, String) == "TRUE"
        number_of_points = 2000
    else
        number_of_points = Meta.parse(get_gtk_property(ent_nr_points, :text, String))
    end

    # Inicjalizujemy płótno, na którym pojawi się wykres (w tym wymiary i nazwę okna).
    c = @GtkCanvas()
    w = GtkWindow(c, "Twój wykres", 900, 800)
    Gtk.showall(w)

    # Podobnie jak w (*), zakresy osi również są albo domyślne, albo ustalone przez użytkownika.
    if get_gtk_property(check_default_lims, :active, String) == "FALSE"                 # Jeśli ten będzie chciał sam je wprowadzić,
        x_lims = Meta.parse.(split(get_gtk_property(ent_xlims, :text, String)))         # Tworzymy z nich dwuelementową macierz
        global xs = LinRange(x_lims[1], x_lims[2], number_of_points)                    # I bierzemy odpowiednią ilość punktów z zakresu od pierwszego do drugiego elementu tej macierzy.
        y_lims = Meta.parse.(split(get_gtk_property(ent_ylims, :text, String)))         # Podobną macierz tworzymy z limitem y.
        global ys = (y_lims[1], y_lims[2])                                              # Ale z kolei z jej elemntów tworzymy tuplę.
        p = FramedPlot(title = p_title, xlabel = p_xlbl, ylabel = p_ylbl, xrange = (x_lims[1], x_lims[2]), yrange = ys)     # Na podstawie tych wartości tworzymy spersonalizowaną płaszczyznę pod wykres.
    else
        global xs = LinRange(-11, 11, number_of_points)
        global ys = (-10,10)
        p = FramedPlot(title = p_title, xlabel = p_xlbl, ylabel = p_ylbl, xrange = (-10,10), yrange = ys)       # W przeciwnym razie płaszczyzna będzie mieć wartości domyślne.
    end

    # Sam wykres funkcji definiujemy dopiero później.
    basic_plot = Curve(xs, trim(f).(xs), color = "red")     # Rysujemy krzywą i punkty (x, y), gdzie y - wartości "przefiltrowane" funkcją trim.
    add(p, basic_plot)                                      # Dorysowujemy wykres do stowrzonej wcześniej płaszczyzny.

    legend_list = [basic_plot]                              # Tworzymy również listę określającą skład legendy.

    # Teraz zajmiemy się szeregiem Taylora
    if get_gtk_property(check_taylor, :active, String) == "TRUE"                # Oczywiście tylko wtedy, kiedy zażąda tego użytkownik.
        x_0 = parse(Float64, get_gtk_property(ent_base_point, :text, String))   # Odczytujemy punk bazowy
        n = parse(Int, get_gtk_property(ent_precision, :text, String))          # oraz dokładność
        s = taylor_expand( f, x_0, order = n)                                   # i tworzymy szereg Taylora
        update!(s, -x_0)                                                        # <- wynika z faktu, że w module TaylorSeries twórcy oznaczają x-x_0 jako t - argument funkcji.
        taylor_plot = Curve(xs, evaluate.(s, xs),color = "blue")                # Tworzymy krzywą.
        add(p, taylor_plot)                                                     # Dodajemy ją do płaszczyzny.
        # Jeśli użytkownik zażąda dodakowo animacji:
        if get_gtk_property(check_anim, :active, String) == "TRUE"
            Taylor(f, x_0, n)                                                   # Wywołujemy stworzoną do tego funkcję.
            win_amin = GtkWindow("Aproksymacja szeregiem Taylora", 900, 800)    # Inicjalizujemy kolejne okno,
            amin = GtkImage("Taylor-expansion.gif")                             # w którym wyświetlimy animację.
            push!(win_amin,amin)
            showall(win_amin)
        end

        # Tworzymu legendę szeregu Taylora i dodajemy ją do listy legend.
        setattr(taylor_plot, label = "Szereg Taylora")
        if get_gtk_property(check_legend, :active, String) == "TRUE"
            push!(legend_list, taylor_plot)
        end

    end

    # Pozostały nam pochodne.
    if get_gtk_property(check_diff, :active, String) == "TRUE"          # Jeśli użytkownik zaznaczy "rysuj pochodne",
        n = parse(Int, get_gtk_property(ent_n_diff, :text, String))     # z odpowiedniego pola ent zostanie pobrany rząd pochodnej.
        @vars x                             # f będzie funkcją zmiennej x.
        df = diff(f, n)                     # tworzymy pochodną z funkcji f rzędu n
        diff_plot = Curve(xs, N.(trim(df).(xs)), color = "green")   # Tworzymy wykres krzywej z punktów pochodnej (y znów "filtrujemy" funkcją trim).
        add(p, diff_plot)                                           # I dodajemy go do płaszczyzny.

        # Znów tworzymy legende i dodajemy ją do listy legend.
        setattr(diff_plot, label = "f^{($(n))}(x)="*repr(df(x)))
        if get_gtk_property(check_legend, :active, String) == "TRUE"
            push!(legend_list, diff_plot)
        end
    end

    # Jeśli użytkownik włączy legendę:
    if get_gtk_property(check_legend, :active, String) == "TRUE"
        setattr(basic_plot, label = "f(x)="*"$(get_gtk_property(ent, :text, String))")  # Na początku dodajemy ją do podstawowego wykresu (podanej funkcji f).
        l = Legend(.1, .9, legend_list)         # A potem, w zależności czego zażyczył użytkownik, dodajemy kolejne.
        add(p,l)                                # Wszystko "upakowujemy" w wykresie.
    end

    # Jeśli użytkownik włączy siatkę:
    if get_gtk_property(check_grid, :active, String) == "TRUE"
        setattr(p.frame1, draw_grid=true)       # Do płaszczyzny dodajemy atrybut - siatkę.
    end

    display(c, p)       # Ostatecznie wyświetlamy wykres.
end

signal_connect(on_button_clicked, btn_draw, "clicked")      # Przypsiujemy funkcjonalność odpoiwedniemy przyciskowi.

showall(win)

%=========================================================================
% FIGURE ANLEGEN
%=========================================================================

f = figure(1);
clf(1,'reset');
set(f,'Position',[220 120 1200 700]);


%=========================================================================
% VOREINSTELLUNGEN & VORABBERECHNUNGEN FÜR DIE DARSTELLUNG
%=========================================================================
% Sprachdatei auswählen
    if Language == 0
        TStrings = EnglishStrings;
    else 
        TStrings = GermanStrings;
    end

% Wegvektor
    x = 0:laenge:(laenge*100);
    % (laenge = Länge eines Leitungsstücks in km)
    
% Zeitfensterbreite einlesen und umrechnen
    % Umrechnen von ms zu s
    % Rahmenbreite teilen, sodass Abstand links und rechts gleich ist
    t_rahmen = Zeitfensterbreite / (1000 * 2) ;

% Subplots anlegen
    % Wanderwellen (Weg auf x-Achse)
    SpannungX = subplot(2,2,1);
    StromX = subplot(2,2,3);
    % Schwingung (Zeit auf x-Achse)
    SpannungT = subplot(2,2,2);
    StromT = subplot(2,2,4);

% Abbruch & Pause / Weiter Button anlegen
    b1 = uicontrol(f,'Style','togglebutton','Position',[762 40 74 24],'String',TStrings.cancel,'FontSize',11);
    b2 = uicontrol(f,'Style','togglebutton','Position',[638 40 113 24],'String',TStrings.pausecontinue,'FontSize',11);
    
% Zeitlupenfaktor-Slider & entsprechende Textfelder anlegen
    % Slider
        s = uicontrol(f,'Style','slider','Min',0,'Max',round(2*Zeitlupenfaktor),'SliderStep',[0.01 0.1],'Value',Zeitlupenfaktor,'Position',[299 40 200 24]);
    % Angabe: "Zeitlupenfaktor:"    
        st1 = uicontrol(f,'Style','text','Position',[160 40 100 21],'FontSize',11,'HorizontalAlignment','left');
        st1.String = sprintf([char([0xD835 0xDF0F]) ' ' char(0x2259) '%0.1f s'],get(s,'Value'));
    % Anfangs- und Endwert des Sliders anzeigen
    st2 = uicontrol(f,'Style','text','Position',[250 40 43 21],'String','0 s','FontSize',11,'HorizontalAlignment','left');
    st3 = uicontrol(f,'Style','text','Position',[508 40 43 21],'String',append(string(2*Zeitlupenfaktor),' s'),'FontSize',11,'HorizontalAlignment','left');

% Slider Darstellungsfortschritt
    Darstellungsposition = 0;
    s1 = uicontrol(f,'Style','slider','Min',0.1,'Max',100,'SliderStep',[0.001 0.01],'Value',Darstellungsposition,'Position',[50 10 1100 24]);
    s1.set('Enable','off');
% Forschrittsanzeige anlegen
    st4 = uicontrol(f,'Style','text','Position',[850 40 300 21],'String',TStrings.presentationprogress,'FontSize',11,'HorizontalAlignment','left');
    
% Min & Max U- & I-Wert in den Matrizen finden
    U_min = min(out.Spannung.signals.values,[],'all');
    I_min = min(out.Strom.signals.values,[],'all');
    U_max = max(out.Spannung.signals.values,[],'all');
    I_max = max(out.Strom.signals.values,[],'all');

% Position der Subplots festlegen
    set(SpannungX,'Position',[0.07 0.59 0.41 0.34]);
    set(StromX,'Position',[0.07 0.159 0.41 0.34]);
    set(SpannungT,'Position',[0.57 0.59 0.41 0.34]);
    set(StromT,'Position',[0.57 0.159 0.41 0.34]);
    
% Handle für die Plots anlegen
    % Wanderwelle - Spannung
        handle_SpannungX = plot(SpannungX,x,out.Spannung.signals.values(1,:),'m');
    % Wanderwelle - Strom
        handle_StromX = plot(StromX,x,out.Strom.signals.values(1,:),'m');
    % Schwingung - Spannung
        handle_SpannungT = plot(SpannungT,out.tout(:,1),out.Spannung.signals.values(:,ErsteSchwingung),'r',...
            out.tout(:,1),out.Spannung.signals.values(:,ZweiteSchwingung),'b');
    % Schwingung - Strom
        handle_StromT = plot(StromT,out.tout(:,1),out.Strom.signals.values(:,ErsteSchwingung),'r',...
            out.tout(:,1),out.Strom.signals.values(:,ZweiteSchwingung),'b');
    
% Überschriften der Diagramme
    st5 = uicontrol(f,'Style','text','Position',[151 652 357 30],'String',...
        TStrings.travellingwaveoverthecompletelength,'FontSize',12,'FontWeight','bold');
    st6 = uicontrol(f,'Style','text','Position',[759 652 357 30],'String',...
        TStrings.oscillationatselectedpositions,'FontSize',12,'FontWeight','bold');
    
% Achsenbeschriftungen
    xlabel(SpannungX,TStrings.distanceinkm);
    ylabel(SpannungX,TStrings.voltageinv);
    xlabel(StromX,TStrings.distanceinkm);
    ylabel(StromX,TStrings.currentina);
    xlabel(SpannungT,TStrings.timeinms);
    ylabel(SpannungT,TStrings.voltageinv);
    xlabel(StromT,TStrings.timeinms);
    ylabel(StromT,TStrings.currentina);
    
% Grid
    grid(SpannungX,'on');
    grid(StromX,'on');
    grid(SpannungT,'on');
    grid(StromT,'on');

% Linien zur Markierung der Schwingungen in den Wanderwellen anlegen
    xline(SpannungX,(ErsteSchwingung-1)*laenge,'--r','LineWidth',1);
    xline(SpannungX,(ZweiteSchwingung-1)*laenge,'--b','LineWidth',1);
    xline(StromX,(ErsteSchwingung-1)*laenge,'--r','LineWidth',1);
    xline(StromX,(ZweiteSchwingung-1)*laenge,'--b','LineWidth',1);
    
% Handle für die Linie des Zeitpunktes der Wanderwellen in den Schwingungen
    handle_ZeitWanderwelleSpannung = xline(SpannungT,out.tout(1,1),'--m','LineWidth',1);
    handle_ZeitWanderwelleStrom = xline(StromT,out.tout(1,1),'--m','LineWidth',1);
    
% Legende für die Schwingungen anlegen
    legend(StromT,[handle_StromT(1) handle_StromT(2)],{sprintf('Position: %d km',...
    (ErsteSchwingung-1)*laenge);sprintf('Position: %d km',(ZweiteSchwingung-1)*laenge)},'Location','southeast');

% Achsenskalierung festlegen
    % Y-Achsen: Min/Max-Wert + 5 %
    % Diagramme mit Weg als X-Achse:
        SpannungX.YLim = [U_min*1.05 U_max*1.05];
        SpannungX.XLim = [0 laenge*100];
        StromX.YLim = [I_min*1.05 I_max*1.05];
        StromX.XLim = [0 laenge*100];
    % Diagramme mit Zeit als X-Achse:
        SpannungT.YLim = [U_min*1.05 U_max*1.05]; 
        StromT.YLim = [I_min*1.05 I_max*1.05];
 
        
%=========================================================================
% ANNIMIERTER PLOT
%=========================================================================

% Laufvariablen deklarieren und initialisieren
    t = 0;
    idx = 0;
    idx_anfang = 0;
    idx_ende = 0;
    idx_alt = 0;
    sliderset = 0;

% Kurze Pause
    pause(2);

% Schleife für die vollständige Annimation
    while idx <= size(out.tout,1) 
        
        % Pause & Abbruch
        %-----------------------------------------------------------------
            % Pause & Abbruch erkennen
                pause_weiter = get(b2,'Value');
                abbruch = get(b1,'Value');
                drawnow;

            % Pause oder Abbruch durchführen
                if abbruch == 1
                    break;
                end
                if pause_weiter == 1
                    if sliderset == 0
                        s1.set('Enable','on');
                        sliderset = 1;
                    end
                else
                    s1.set('Enable','off');
                    sliderset = 0;
                end
                
        if pause_weiter~=1
                    
            % Indexbestimmung 
            %-----------------------------------------------------------------
                % Zeitmessung starten (PC-Rechendauer messen)
                    tic
    
                % Aktuellen Zeitlupenfaktor einlesen
                    st1.String = sprintf([char([0xD835 0xDF0F]) ' ' char(0x2259) '%0.1f s'],get(s,'Value'));
                    drawnow;
                    t_fak = Tau/get(s,'Value');
    
                % Index des Zeitvektors suchen, der der gesuchten
                % Zeit am nächsten kommt
                    [~, idx] = min(abs(out.tout - (t)));
    
                % Abbruch der While-Schleife, wenn das Ende der
                % Datensätze erreicht ist, sonst endlose Schleife
                    if idx_alt == idx
                        break;
                    end
                    
            % Plot der Wanderwellen
            %-----------------------------------------------------------------
                set(handle_SpannungX,'YData',out.Spannung.signals.values(idx,:));
                set(handle_StromX,'YData',out.Strom.signals.values(idx,:));
    
                
            % Plot der Schwingungen
            %-----------------------------------------------------------------
                % Indizes des Schwingungs-Zeitfenster bestimmen
                    if (t - t_rahmen) <= 0
                        % Fall: t <= linker Zeitfensterrand
                        idx_anfang = 1;
                        [~, idx_ende] = min(abs(out.tout - (2 * t_rahmen)));
                    else
                        if (t + t_rahmen) > out.tout(end,1)
                            % Fall: t > rechter Zeitfensterrand
                            [~, idx_anfang] = min(abs(out.tout - (out.tout(end) - (2 * t_rahmen))));
                            idx_ende = size(out.tout,1);
                        else
                            % Fall: beide Zeitfensterränder können
                            % vollständig dargestellt werden
                            [~, idx_anfang] = min(abs(out.tout - (t - t_rahmen)));
                            [~, idx_ende] = min(abs(out.tout - (t + t_rahmen)));
                        end
                    end
    
                % X-Achsen für gleitendes Zeitfenster anpassen
                    SpannungT.XLim = [out.tout(idx_anfang,1) out.tout(idx_ende,1)];
                    StromT.XLim = [out.tout(idx_anfang,1) out.tout(idx_ende,1)];
                    
                % Plot der ersten Schwingung
                    set(handle_SpannungT(1),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Spannung.signals.values(idx_anfang:idx_ende,ErsteSchwingung));
                    set(handle_StromT(1),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Strom.signals.values(idx_anfang:idx_ende,ErsteSchwingung));
                    
                % Plot der zweiten Schwingung 
                    set(handle_SpannungT(2),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Spannung.signals.values(idx_anfang:idx_ende,ZweiteSchwingung));
                    set(handle_StromT(2),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Strom.signals.values(idx_anfang:idx_ende,ZweiteSchwingung));
                    
                % Plot des Zeitpunktes der Wanderwelle
                    handle_ZeitWanderwelleSpannung.Value = out.tout(idx,1);
                    handle_ZeitWanderwelleStrom.Value = out.tout(idx,1);
    
                    
            % Abschließende Berechnungen
            %-----------------------------------------------------------------
                % Fortschrittsanzeige anpassen
                    st4.String = sprintf([TStrings.presentationprogress ' %.0f %%'],idx * 100 / size(out.tout,1));
                % Darstellungsfortschritt-Slider anpassen
                    s1.set('Value',round(idx * 100 / size(out.tout,1)));
                    
                % Alle Plots aktualisieren
                    drawnow nocallbacks; 
                    
                % Aktuellen Index abspeichern (für Abbruch der While-Schleife)
                    idx_alt = idx;
    
                % Zeit, die für einen Durchlauf der While-Schleife
                % benötigt wurde zur Gesamtlaufzeit aufaddieren
                    t = t + toc*t_fak;
        else
            Darstellungsfortschritt = get(s1,'Value');
            idx_slider = round(Darstellungsfortschritt*size(out.tout,1)/100);
            t_slider = out.tout(idx_slider);
            % Plot der Wanderwellen
            %-----------------------------------------------------------------
                set(handle_SpannungX,'YData',out.Spannung.signals.values(idx_slider,:));
                set(handle_StromX,'YData',out.Strom.signals.values(idx_slider,:));
    
                
            % Plot der Schwingungen
            %-----------------------------------------------------------------
                % Indizes des Schwingungs-Zeitfenster bestimmen
                    if (t_slider - t_rahmen) <= 0
                        % Fall: t <= linker Zeitfensterrand
                        idx_anfang = 1;
                        [~, idx_ende] = min(abs(out.tout - (2 * t_rahmen)));
                    else
                        if (t_slider + t_rahmen) > out.tout(end,1)
                            % Fall: t > rechter Zeitfensterrand
                            [~, idx_anfang] = min(abs(out.tout - (out.tout(end) - (2 * t_rahmen))));
                            idx_ende = size(out.tout,1);
                        else
                            % Fall: beide Zeitfensterränder können
                            % vollständig dargestellt werden
                            [~, idx_anfang] = min(abs(out.tout - (t_slider - t_rahmen)));
                            [~, idx_ende] = min(abs(out.tout - (t_slider + t_rahmen)));
                        end
                    end
    
                % X-Achsen für gleitendes Zeitfenster anpassen
                    SpannungT.XLim = [out.tout(idx_anfang,1) out.tout(idx_ende,1)];
                    StromT.XLim = [out.tout(idx_anfang,1) out.tout(idx_ende,1)];
                    
                % Plot der ersten Schwingung
                    set(handle_SpannungT(1),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Spannung.signals.values(idx_anfang:idx_ende,ErsteSchwingung));
                    set(handle_StromT(1),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Strom.signals.values(idx_anfang:idx_ende,ErsteSchwingung));
                    
                % Plot der zweiten Schwingung 
                    set(handle_SpannungT(2),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Spannung.signals.values(idx_anfang:idx_ende,ZweiteSchwingung));
                    set(handle_StromT(2),'XData',out.tout(idx_anfang:idx_ende,1),'YData',out.Strom.signals.values(idx_anfang:idx_ende,ZweiteSchwingung));
                    
                % Plot des Zeitpunktes der Wanderwelle
                    handle_ZeitWanderwelleSpannung.Value = out.tout(idx_slider,1);
                    handle_ZeitWanderwelleStrom.Value = out.tout(idx_slider,1); 
            % Abschließende Berechnungen
            %-----------------------------------------------------------------
                % Fortschrittsanzeige anpassen
                    st4.String = sprintf([TStrings.presentationprogressslider ' %.0f %%'],Darstellungsfortschritt);
                    
                % Alle Plots aktualisieren
                    drawnow nocallbacks; 
        end
    end

    
%=========================================================================
% ENDE DER DARSTELLUNG
%=========================================================================

% Fortschrittsanzeige anpassen
    st4.String = TStrings.presentationfinished;
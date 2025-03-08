# Documentatie van het PowerShell Script voor Windows Autopilot

## Inleiding

Dit PowerShell-script is ontworpen om te interageren met de Windows Autopilot-service van Microsoft via de Microsoft Graph API. Het script biedt functionaliteit voor het beheren van apparaten die zijn geregistreerd in Windows Autopilot, inclusief het ophalen van apparaatgegevens, het synchroniseren van apparaten tussen Autopilot en Intune, en het verwijderen van apparaten in bulk. Dit is bijzonder nuttig voor IT-beheerders die verantwoordelijk zijn voor het beheren van apparaten in een organisatie, vooral tijdens het in- en uitfaseren van hardware.

## Vereisten

Voordat je het script uitvoert, moet je ervoor zorgen dat de benodigde modules zijn geïnstalleerd:

- **Microsoft.Graph.Intune**: Deze module biedt cmdlets voor het beheren van Intune en Windows Autopilot.

## Functies

### `Get-AutoPilotDevice`

#### Doel
De `Get-AutoPilotDevice` functie haalt apparaten op die momenteel zijn geregistreerd bij Windows Autopilot. Dit kan een volledige lijst van apparaten zijn of een specifiek apparaat op basis van een opgegeven ID of serienummer.

#### Werking
- **Parameters**:
  - `id`: Optioneel. Het ID (GUID) van een specifiek Windows Autopilot-apparaat.
  - `serial`: Optioneel. Het serienummer van het specifieke Windows Autopilot-apparaat dat moet worden opgehaald.
  - `expand`: Optioneel. Een switch om de eigenschappen van het apparaat uit te breiden met informatie over het Autopilot-profiel.
  
- **Proces**:
  - De functie bouwt een URI op voor de Microsoft Graph API op basis van de opgegeven parameters.
  - Het maakt gebruik van de `Invoke-MSGraphRequest` cmdlet om de gegevens op te halen.
  - Als er meerdere pagina's met resultaten zijn, worden deze opgehaald en samengevoegd.

#### Bijdrage aan het script
Deze functie is essentieel voor het ophalen van informatie over geregistreerde apparaten, wat helpt bij het beheren en controleren van de status van apparaten in Windows Autopilot.

### `Invoke-AutopilotSync`

#### Doel
De `Invoke-AutopilotSync` functie initieert een synchronisatie van Windows Autopilot-apparaten tussen de Autopilot-implementatieservice en Intune.

#### Werking
- **Parameters**: Geen.
- **Proces**:
  - De functie bouwt een URI op voor de synchronisatie-aanroep en gebruikt de `Invoke-MSGraphRequest` cmdlet om de synchronisatie te starten.

#### Bijdrage aan het script
Deze functie zorgt ervoor dat nieuwe of gewijzigde apparaten correct worden gesynchroniseerd met Intune, wat cruciaal is voor het bijhouden van de status van apparaten in de organisatie.

### `Start-AutopilotCleanupCSV`

#### Doel
De `Start-AutopilotCleanupCSV` functie verwerkt een lijst van Autopilot-apparaten en verwijdert deze in bulk uit Autopilot en, indien gewenst, uit Intune. Dit is handig voor het opschonen van apparaten die niet langer in gebruik zijn.

#### Werking
- **Parameters**:
  - `CsvFile`: Verplicht. Het pad naar het CSV-bestand met de serienummers van de te verwijderen apparaten.
  - `IntuneCleanup`: Optioneel. Een switch om de verwijdering van het Intune-beheerde apparaatsobject op te nemen.
  - `ShowCleanupRequestOnly`: Optioneel. Een switch om alleen de ruwe batchverzoekdefinitie weer te geven voor debugging.

- **Proces**:
  - De functie importeert de serienummers uit het opgegeven CSV-bestand.
  - Het bouwt batchverzoeken op voor de verwijdering van apparaten, met een maximum van 20 verzoeken per batch (volgens de Microsoft Graph API-limieten).
  - Na het indienen van de batchverzoeken, toont het de status van de verwijderingsverzoeken.

#### Bijdrage aan het script
Deze functie maakt het eenvoudig om meerdere apparaten tegelijk te verwijderen, wat tijd bespaart en de efficiëntie verhoogt bij het beheren van apparaten in de organisatie.

## Hoofdlogica

1. **Initialisatie**: Controleert of de benodigde module is geïnstalleerd en importeert deze.
2. **Verbinding maken met Microsoft Graph**: Verbindt met de Microsoft Graph API.
3. **Opruimen van apparaten**: Voert de `Start-AutopilotCleanupCSV` functie uit om apparaten te verwijderen op basis van de gegevens in het CSV-bestand.
4. **Wachten op verwijdering**

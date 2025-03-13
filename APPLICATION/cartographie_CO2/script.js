// Variables globales
let map;
let geocoder;
let startMarker;
let endMarker;
let startLocation;
let endLocation;
let embedMode = false;
// Ajouter ces variables globales
let directionsService;
let routeLines = [];
// Variables pour la météo
let weatherMarkers = [];
let weatherVisible = false;
let weatherData = {};

// Définition du centre et des limites de la région Occitanie
const OCCITANIE_CENTER = { lat: 43.8927, lng: 3.2828 };
const OCCITANIE_BOUNDS = {
    north: 45.5,
    south: 42.3,
    east: 4.9,
    west: 0.5
};

// Liste des villes principales d'Occitanie pour les suggestions
const OCCITANIE_CITIES = [
    "Toulouse",
    "Montpellier",
    "Nîmes",
    "Perpignan",
    "Béziers",
    "Montauban",
    "Narbonne",
    "Albi",
    "Carcassonne",
    "Sète",
    "Castres",
    "Tarbes",
    "Alès",
    "Colomiers",
    "Agde",
    "Tournefeuille",
    "Muret",
    "Lunel",
    "Rodez",
    "Blagnac",
    "Frontignan",
    "Millau",
    "Auch",
    "Castelnau-le-Lez",
    "Cahors",
    "Bagnols-sur-Cèze",
    "Plaisance-du-Touch",
    "Cugnaux",
    "Mauguio",
    "Lattes",
    "Beaucaire",
    "Balma",
    "Gaillac",
    "Pamiers",
    "Lourdes",
    "Castelsarrasin",
    "Ramonville-Saint-Agne",
    "Saint-Gilles",
    "Castanet-Tolosan",
    "Moissac",
    "Graulhet",
    "Canet-en-Roussillon",
    "Onet-le-Château",
    "Villefranche-de-Rouergue",
    "Fonsorbes",
    "Saint-Estève",
    "Mende",
    "Saint-Orens-de-Gameville",
    "L'Union",
    "Mèze",
    "Villeneuve-lès-Avignon",
    "Vauvert",
    "Saint-Gaudens",
    "Lézignan-Corbières",
    "Castelnaudary",
    "Lavaur",
    "Juvignac",
    "Saint-Jean",
    "Saint-Cyprien",
    "Argelès-sur-Mer",
    "Saint-Laurent-de-la-Salanque",
    "Pont-Saint-Esprit",
    "Limoux",
    "Mazamet",
    "Castelginest",
    "Saint-Gély-du-Fesc",
    "Figeac",
    "Cabestany",
    "Portet-sur-Garonne",
    "Foix",
    "Villeneuve-lès-Maguelone",
    "Revel",
    "Carmaux",
    "Auterive",
    "Le Crès",
    "Saint-Lys",
    "Villeneuve-Tolosane",
    "Saint-Jean-de-Védas",
    "Pérols",
    "Léguevin",
    "Frouzins",
    "Saint-Sulpice-la-Pointe",
    "La Grande-Motte",
    "Pia",
    "Grenade",
    "Rivesaltes",
    "Clermont-l'Hérault",
    "Elne",
    "Seysses",
    "Marguerittes",
    "L'Isle-Jourdain",
    "Uzès",
    "Le Grau-du-Roi",
    "Les Angles",
    "Aigues-Mortes",
    "Pibrac",
    "Launaguet",
    "Saint-Affrique",
    "Pézenas",
    "Aucamville",
    "La Salvetat-Saint-Gilles",
    "Grabels",
    "Aureilhan",
    "Marseillan",
    "Céret",
    "Le Soler",
    "Bagnères-de-Bigorre",
    "Rochefort-du-Gard",
    "Lodève",
    "Thuir",
    "Bompas",
    "Baillargues",
    "Saint-Christol-lez-Alès",
    "Aussonne",
    "Sérignan",
    "Balaruc-les-Bains",
    "Bellegarde",
    "Caussade",
    "Saint-Juéry",
    "Jacou",
    "Fabrègues",
    "Manduel",
    "Condom",
    "Toulouges",
    "Pignan",
    "Labruguière",
    "Cornebarrieu",
    "Escalquens",
    "Gigean",
    "Saint-Girons",
    "Bouillargues",
    "Montech",
    "Marsillargues",
    "Lavelanet",
    "Beauzelle",
    "Fleurance",
    "Palavas-les-Flots",
    "Vendargues",
    "Castelnau-d'Estrétefonds",
    "Laudun-l'Ardoise",
    "Aussillon",
    "Castries",
    "Prades",
    "Poussan",
    "Eaunes",
    "Saint-Alban",
    "Bédarieux",
    "Gignac",
    "Luc-la-Primaube",
    "Fronton"
  ];

// Facteurs d'émission de CO2 en g/km par passager
const CO2_FACTORS = {
    train: 24.44,       // Train régional (TER, Intercités)

    bus: 68,         // Bus urbain
    car_solo: 200,   // Voiture individuelle
    //car_shared: 0,  // Voiture partagée (2 personnes)
};

// Initialisation de l'application
function initApp() {
    // Initialiser la carte
    map = new google.maps.Map(document.getElementById('map'), {
        center: OCCITANIE_CENTER,
        zoom: 8,
        mapTypeControl: true,
        fullscreenControl: true,
        streetViewControl: true,
        zoomControl: true
    });

    // Restreindre la carte à la région Occitanie
    map.setOptions({
        restriction: {
            latLngBounds: OCCITANIE_BOUNDS,
            strictBounds: false
        }
    });

    // Initialiser le service de géocodage
    geocoder = new google.maps.Geocoder();

    // Initialiser les marqueurs
    startMarker = new google.maps.Marker({
        map: map,
        icon: {
            url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png',
            scaledSize: new google.maps.Size(32, 32)
        },
        visible: false
    });

    endMarker = new google.maps.Marker({
        map: map,
        icon: {
            url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png',
            scaledSize: new google.maps.Size(32, 32)
        },
        visible: false
    });

    // Configurer les champs de saisie
    setupInputField('start-point', 'start-suggestions', (location) => {
        startLocation = location;
        startMarker.setPosition(location);
        startMarker.setVisible(true);
        map.setCenter(location);
        map.setZoom(14);
    });

    setupInputField('end-point', 'end-suggestions', (location) => {
        endLocation = location;
        endMarker.setPosition(location);
        endMarker.setVisible(true);
        map.setCenter(location);
        map.setZoom(14);
    });

    // Ajouter l'écouteur d'événement pour le bouton de recherche
    document.getElementById('find-route').addEventListener('click', showEmbeddedDirections);

    // Ajouter l'écouteur d'événement pour les clics sur la carte
    map.addListener('click', function(event) {
        // Si nous sommes en mode embed, revenir à la carte normale
        if (embedMode) {
            resetMap();
            return;
        }
        
        const clickedLocation = event.latLng;
        
        // Si le point de départ n'est pas défini, le définir
        if (!startLocation) {
            startLocation = clickedLocation;
            startMarker.setPosition(clickedLocation);
            startMarker.setVisible(true);
            
            // Obtenir l'adresse pour le point cliqué
            geocodeLocation(clickedLocation, function(address) {
                document.getElementById('start-point').value = address;
            });
        } 
        // Sinon, si la destination n'est pas définie, la définir
        else if (!endLocation) {
            endLocation = clickedLocation;
            endMarker.setPosition(clickedLocation);
            endMarker.setVisible(true);
            
            // Obtenir l'adresse pour le point cliqué
            geocodeLocation(clickedLocation, function(address) {
                document.getElementById('end-point').value = address;
            });
        }
    });
}

// Configurer un champ de saisie avec suggestions
function setupInputField(inputId, suggestionsId, onLocationSelected) {
    const inputElement = document.getElementById(inputId);
    const suggestionsElement = document.getElementById(suggestionsId);
    
    // Ajouter un écouteur pour l'entrée de texte
    inputElement.addEventListener('input', function() {
        const inputValue = this.value.toLowerCase();
        
        // Si la valeur est vide, cacher les suggestions
        if (!inputValue) {
            suggestionsElement.style.display = 'none';
            return;
        }
        
        // Filtrer les villes qui correspondent à l'entrée
        const matchingCities = OCCITANIE_CITIES.filter(city => 
            city.toLowerCase().includes(inputValue)
        );
        
        // Afficher les suggestions
        if (matchingCities.length > 0) {
            suggestionsElement.innerHTML = '';
            matchingCities.forEach(city => {
                const item = document.createElement('div');
                item.className = 'suggestion-item';
                item.textContent = city;
                item.addEventListener('click', function() {
                    inputElement.value = city;
                    suggestionsElement.style.display = 'none';
                    
                    // Géocoder la ville sélectionnée
                    geocodeAddress(city + ', Occitanie, France', function(location) {
                        if (location) {
                            onLocationSelected(location);
                        }
                    });
                });
                suggestionsElement.appendChild(item);
            });
            suggestionsElement.style.display = 'block';
        } else {
            suggestionsElement.style.display = 'none';
        }
    });
    
    // Cacher les suggestions quand on clique ailleurs
    document.addEventListener('click', function(event) {
        if (event.target !== inputElement && !suggestionsElement.contains(event.target)) {
            suggestionsElement.style.display = 'none';
        }
    });
    
    // Gérer la touche Entrée
    inputElement.addEventListener('keydown', function(event) {
        if (event.key === 'Enter') {
            const value = this.value;
            if (value) {
                suggestionsElement.style.display = 'none';
                
                // Géocoder l'adresse saisie
                geocodeAddress(value + ', Occitanie, France', function(location) {
                    if (location) {
                        onLocationSelected(location);
                    }
                });
            }
        }
    });
}

// Fonction pour géocoder une adresse
function geocodeAddress(address, callback) {
    geocoder.geocode({ 'address': address, 'region': 'fr' }, function(results, status) {
        if (status === google.maps.GeocoderStatus.OK && results[0]) {
            const location = results[0].geometry.location;
            
            // Vérifier si le lieu est dans les limites de l'Occitanie
            if (isInOccitanie(location.lat(), location.lng())) {
                callback(location);
            } else {
                alert('Le lieu sélectionné n\'est pas en Occitanie.');
            }
        } else {
            alert('Impossible de trouver ce lieu. Veuillez essayer une autre adresse.');
        }
    });
}

// Fonction pour géocoder une position en adresse
function geocodeLocation(location, callback) {
    geocoder.geocode({ 'location': location }, function(results, status) {
        if (status === google.maps.GeocoderStatus.OK && results[0]) {
            callback(results[0].formatted_address);
        } else {
            callback('Position sélectionnée');
        }
    });
}

// Fonction pour calculer la distance entre deux points en km
function calculateDistance(point1, point2) {
    const R = 6371; // Rayon de la Terre en km
    const dLat = (point2.lat() - point1.lat()) * Math.PI / 180;
    const dLon = (point2.lng() - point1.lng()) * Math.PI / 180;
    const a = 
        Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(point1.lat() * Math.PI / 180) * Math.cos(point2.lat() * Math.PI / 180) * 
        Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const distance = R * c;
    
    // Ajouter un facteur pour tenir compte des routes (pas en ligne droite)
    return distance * 1.3;
}

// Fonction pour générer le HTML des émissions de CO2
function generateCO2EmissionsHTML(distanceKm) {
    // Calculer les émissions pour chaque mode de transport
    const emissions = {
        train: Math.round(CO2_FACTORS.train * distanceKm),
        
        bus: Math.round(CO2_FACTORS.bus * distanceKm),
        car_solo: Math.round(CO2_FACTORS.car_solo * distanceKm)
    };

    // Déterminer le mode de transport le plus écologique (hors vélo et marche)
    let lowestEmission = Number.MAX_VALUE;
    let mostEcoMode = '';
    
    for (const [mode, emission] of Object.entries(emissions)) {
        if (emission > 0 && emission < lowestEmission) {
            lowestEmission = emission;
            mostEcoMode = mode;
        }
    }

    // Traduire les noms des modes de transport
    const modeNames = {
        train: 'Train régional (TER)',
       
        bus: 'Bus',
        car_solo: 'Voiture (seul)',

    };

    // Générer le HTML
    let html = `
        <div class="co2-section">
            <h3>Émissions de CO2 pour ce trajet</h3>
            <p class="co2-intro">Comparez l'impact environnemental des différents modes de transport pour ce trajet de <strong>${distanceKm.toFixed(1)}km</strong></p>
            
            <div class="co2-bars">
    `;

    // Ajouter les barres pour chaque mode de transport
    for (const [mode, emission] of Object.entries(emissions)) {
        // Calculer la largeur de la barre (max 100%)
        const maxEmission = emissions.car_solo;
        const barWidth = Math.max(5, Math.round((emission / maxEmission) * 100));
        
        // Déterminer la couleur de la barre
        let barColor;
        if (emission === 0) {
            barColor = '#ffffff'; // blanc pour zéro émission
        } else if (emission < emissions.bus) {
            barColor = '#34a853'; // vert pour faible émission
        } else if (emission < emissions.car_solo) {
            barColor = '#fbbc05'; // Jaune pour émission moyenne
        } else {
            barColor = '#ea4335'; // Rouge pour forte émission
        }
        
        html += `
            <div class="co2-bar-container">
                <div class="co2-bar-label">${modeNames[mode]}</div>
                <div class="co2-bar-wrapper">
                    <div class="co2-bar" style="width: ${barWidth}%; background-color: ${barColor};"></div>
                    <span class="co2-bar-value">${emission} g</span>
                </div>
            </div>
        `;
    }

    // Ajouter l'analyse comparative
    const trainVsCar = Math.round(((emissions.car_solo - emissions.train) / emissions.car_solo) * 100);
    
    html += `
            </div>
            
            <div class="co2-analysis">
                <h4>Analyse comparative</h4>
                <p>En choisissant le <strong>train</strong> plutôt que la <strong>voiture</strong> individuelle pour ce trajet, vous réduisez vos émissions de CO2 de <strong>${trainVsCar}%</strong>.</p>
                <p>Le mode de transport le plus écologique pour ce trajet est le <strong>${
                    distanceKm <= 5 ? 'le vélo ou la marche' : 
                    modeNames[mostEcoMode]
                }</strong>.</p>
            </div>
        </div>
    `;

    return html;
}

// Fonction pour afficher l'itinéraire avec Maps Embed API
// Remplacez la fonction showEmbeddedDirections par celle-ci
// Modifiez la fonction showEmbeddedDirections
async function showEmbeddedDirections() {
    console.log("Recherche d'itinéraire...");
    
    // Afficher le spinner de chargement
    document.getElementById('loading').style.display = 'block';
    
    // Vérifier si les lieux ont été correctement sélectionnés
    if (!startLocation || !endLocation) {
        document.getElementById('loading').style.display = 'none';
        document.getElementById('results').innerHTML = '<div class="error">Veuillez sélectionner un lieu de départ et une destination.</div>';
        return;
    }

    // Calculer la distance approximative entre les deux points
    const distanceKm = calculateDistance(startLocation, endLocation);
    console.log("Distance calculée :", distanceKm, "km");
    
    // Obtenir la recommandation de transport
    const recommendation = await recommendTransportMode(startLocation, endLocation);
    console.log("Recommandation:", recommendation);

    // Convertir les coordonnées en chaînes de caractères
    const startStr = startLocation.lat() + ',' + startLocation.lng();
    const endStr = endLocation.lat() + ',' + endLocation.lng();
    
    // Obtenir les adresses pour affichage
    geocodeLocation(startLocation, function(startAddress) {
        geocodeLocation(endLocation, function(endAddress) {
            console.log("Adresses obtenues :", startAddress, "->", endAddress);
            
            // Masquer le spinner de chargement
            document.getElementById('loading').style.display = 'none';
            
            // Créer l'iframe avec l'API Maps Embed
            const mapContainer = document.getElementById('map');
            mapContainer.innerHTML = `
                <iframe
                    width="100%"
                    height="100%"
                    frameborder="0" 
                    style="border:0"
                    src="https://www.google.com/maps/embed/v1/directions?key=AIzaSyAfFOJwfawxLAW38yATY7MSTI2ikioEMPE
                        &origin=${encodeURIComponent(startStr)}
                        &destination=${encodeURIComponent(endStr)}
                        &mode=${recommendation.mode}"
                    allowfullscreen>
                </iframe>
            `;
            
            // Marquer que nous sommes en mode embed
            embedMode = true;
            
            // Générer le HTML pour les émissions de CO2
            const co2HTML = generateCO2EmissionsHTML(distanceKm);
            
            // Afficher les résultats
            const resultsDiv = document.getElementById('results');
            resultsDiv.innerHTML = '';
            
            // Créer et ajouter le résumé de l'itinéraire avec la recommandation
            const routeSummary = document.createElement('div');
            routeSummary.className = 'route-summary';
            
            // Ajouter les informations météo et la recommandation
            // Ajouter les informations météo et la recommandation
            const weatherHTML = `
            <div class="weather-info">
                <h3>Conditions météo actuelles</h3>
                <div class="weather-details">
                    <img src="https:${recommendation.weather.icon}" alt="${recommendation.weather.condition}">
                    <div>
                        <p>${recommendation.weather.condition}</p>
                        <p>${recommendation.weather.temperature}°C, vent: ${recommendation.weather.wind} km/h</p>
                    </div>
                </div>
                <div class="recommendation">
                    <h4>Recommandation</h4>
                    <p>Mode de transport recommandé: <strong>${getTransportModeName(recommendation.mode)}</strong></p>
                    <p>${recommendation.reason}</p>
                </div>
            </div>
            `;
            
            routeSummary.innerHTML = `
                <p>Itinéraire de <strong>${startAddress}</strong> à <strong>${endAddress}</strong></p>
                <p>Distance approximative: <strong>${distanceKm.toFixed(1)} km</strong></p>
                ${weatherHTML}
                <p>Consultez la carte pour les détails de l'itinéraire.</p>
            `;
            
            // Ajouter le bouton de réinitialisation
            const resetButton = document.createElement('button');
            resetButton.id = 'reset-map';
            resetButton.className = 'btn';
            resetButton.textContent = 'Réinitialiser la carte';
            resetButton.addEventListener('click', resetMap);
            
            const buttonContainer = document.createElement('p');
            buttonContainer.appendChild(resetButton);
            routeSummary.appendChild(buttonContainer);
            
            // Ajouter le résumé à la div des résultats
            resultsDiv.appendChild(routeSummary);
            
            // Créer un élément div pour les émissions de CO2
            const co2Section = document.createElement('div');
            co2Section.innerHTML = co2HTML;
            
            // Ajouter la section des émissions de CO2 à la div des résultats
            resultsDiv.appendChild(co2Section.firstElementChild);
        });
    });
}

// Fonction pour obtenir le nom lisible du mode de transport
function getTransportModeName(mode) {
    const modes = {
        'transit': 'Transports en commun :Train',
        'driving': 'Voiture',
        'walking': 'Marche à pied',
        'bicycling': 'Vélo',
        'train': 'Train'
    };
    return modes[mode] || mode;
}
// Fonction pour réinitialiser la carte
function resetMap() {
    // Recréer la carte
    map = new google.maps.Map(document.getElementById('map'), {
        center: OCCITANIE_CENTER,
        zoom: 8,
        mapTypeControl: true,
        fullscreenControl: true,
        streetViewControl: true,
        zoomControl: true
    });
    
    // Restreindre la carte à la région Occitanie
    map.setOptions({
        restriction: {
            latLngBounds: OCCITANIE_BOUNDS,
            strictBounds: false
        }
    });
    
    // Réinitialiser les marqueurs
    startMarker = new google.maps.Marker({
        map: map,
        icon: {
            url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png',
            scaledSize: new google.maps.Size(32, 32)
        },
        visible: false
    });
    
    endMarker = new google.maps.Marker({
        map: map,
        icon: {
            url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png',
            scaledSize: new google.maps.Size(32, 32)
        },
        visible: false
    });
    
    // Réafficher les marqueurs si des positions sont définies
    if (startLocation) {
        startMarker.setPosition(startLocation);
        startMarker.setVisible(true);
    }
    
    if (endLocation) {
        endMarker.setPosition(endLocation);
        endMarker.setVisible(true);
    }
    
    // Ajouter l'écouteur d'événement pour les clics sur la carte
    map.addListener('click', function(event) {
        const clickedLocation = event.latLng;
        
        // Si le point de départ n'est pas défini, le définir
        if (!startLocation) {
            startLocation = clickedLocation;
            startMarker.setPosition(clickedLocation);
            startMarker.setVisible(true);
            
            // Obtenir l'adresse pour le point cliqué
            geocodeLocation(clickedLocation, function(address) {
                document.getElementById('start-point').value = address;
            });
        } 
        // Sinon, si la destination n'est pas définie, la définir
        else if (!endLocation) {
            endLocation = clickedLocation;
            endMarker.setPosition(clickedLocation);
            endMarker.setVisible(true);
            
            // Obtenir l'adresse pour le point cliqué
            geocodeLocation(clickedLocation, function(address) {
                document.getElementById('end-point').value = address;
            });
        }
    });
    
    // Marquer que nous ne sommes plus en mode embed
    embedMode = false;
    
    // Réinitialiser le message dans les résultats
    document.getElementById('results').innerHTML = '<p>Saisissez un lieu de départ et une destination pour afficher les itinéraires en transport en commun.</p>';
}

// Fonction pour vérifier si un point est dans les limites de l'Occitanie
function isInOccitanie(lat, lng) {
    return lat >= OCCITANIE_BOUNDS.south && 
           lat <= OCCITANIE_BOUNDS.north && 
           lng >= OCCITANIE_BOUNDS.west && 
           lng <= OCCITANIE_BOUNDS.east;
}

// Fonction pour vérifier si la page est chargée dans un iframe Shiny
function isInShinyFrame() {
    try {
        return window.parent && window.parent.Shiny;
    } catch (e) {
        return false;
    }
}

// Fonction pour envoyer des données à Shiny
function sendToShiny(name, data) {
    if (isInShinyFrame()) {
        window.parent.Shiny.setInputValue(name, data);
    }
}

// Vérifier les paramètres d'URL pour les modes spéciaux
document.addEventListener('DOMContentLoaded', function() {
    // Récupérer les paramètres d'URL
    const urlParams = new URLSearchParams(window.location.search);
    const mode = urlParams.get('mode');
    
    // Appliquer des modifications en fonction du mode
    if (mode === 'search_only') {
        // Cacher la carte et ne montrer que la recherche
        const mapContainer = document.querySelector('.map-container');
        const sidebar = document.querySelector('.sidebar');
        
        if (mapContainer && sidebar) {
            mapContainer.style.display = 'none';
            sidebar.style.width = '100%';
        }
    }
    
    // Informer Shiny que la carte est chargée
    sendToShiny('map_loaded', true);
});

// Fonction pour recevoir des commandes de Shiny
window.receiveFromShiny = function(command, params) {
    console.log('Commande reçue de Shiny:', command, params);
    
    switch (command) {
        case 'setRoute':
            // Définir un itinéraire depuis Shiny
            if (params.origin && params.destination) {
                document.getElementById('start-point').value = params.origin;
                document.getElementById('end-point').value = params.destination;
                
                // Géocoder les adresses et afficher l'itinéraire
                geocodeAddress(params.origin + ', Occitanie, France', function(location) {
                    if (location) {
                        startLocation = location;
                        startMarker.setPosition(location);
                        startMarker.setVisible(true);
                        
                        geocodeAddress(params.destination + ', Occitanie, France', function(location) {
                            if (location) {
                                endLocation = location;
                                endMarker.setPosition(location);
                                endMarker.setVisible(true);
                                
                                // Rechercher l'itinéraire
                                showEmbeddedDirections();
                            }
                        });
                    }
                });
            }
            break;
            
        case 'resetMap':
            // Réinitialiser la carte
            resetMap();
            break;
    }
};
//##################


// Fonction pour récupérer les données météo
async function getWeatherData(lat, lng) {
    const apiKey = 'af48c02926354057aa3130845251301';
    const url = `https://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${lat},${lng}&aqi=no`;
    
    try {
        const response = await fetch(url);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Erreur lors de la récupération des données météo:', error);
        return null;
    }
}

// Fonction pour recommander un mode de transport basé sur la météo et la distance
async function recommendTransportMode(startLoc, endLoc) {
    // Calculer la distance
    const distanceKm = calculateDistance(startLoc, endLoc);
    
    // Récupérer la météo au point de départ
    const weatherData = await getWeatherData(startLoc.lat(), startLoc.lng());
    
    if (!weatherData) return { mode: 'transit', reason: 'Données météo non disponibles' };
    
    const condition = weatherData.current.condition.text.toLowerCase();
    const tempC = weatherData.current.temp_c;
    const windKph = weatherData.current.wind_kph;
    const isRaining = condition.includes('rain') || condition.includes('drizzle');
    const isSnowing = condition.includes('snow') || condition.includes('sleet');
    const isFoggy = condition.includes('fog') || condition.includes('mist');
    
    // Logique de recommandation
    let recommendedMode = 'transit'; // Par défaut: transports en commun
    let reason = '';
    
    // Pour les courtes distances
    if (distanceKm <= 2) {
        if (isRaining || isSnowing) {
            recommendedMode = 'transit';
            reason = 'Précipitations détectées - restez au sec';
        } else if (tempC > 30) {
            recommendedMode = 'transit';
            reason = 'Température élevée - évitez l\'effort physique';
        } else {
            recommendedMode = 'walking';
            reason = 'Distance courte et météo favorable';
        }
    } 
    // Pour les distances moyennes
    else if (distanceKm <= 10) {
        if (isRaining || isSnowing || windKph > 30) {
            recommendedMode = 'transit';
            reason = 'Conditions météo défavorables';
        } else if (isFoggy) {
            recommendedMode = 'transit';
            reason = 'Visibilité réduite';
        } else {
            recommendedMode = 'transit';
            reason = 'Distance moyenne et météo favorable';
        }
    } 
    // Pour les longues distances
    else {
        if (isSnowing || isFoggy || windKph > 50) {
            recommendedMode = 'train';
            reason = 'Conditions météo difficiles - privilégiez le train';
        } else if (isRaining) {
            recommendedMode = 'transit';
            reason = 'Pluie détectée - transports en commun recommandés';
        } else {
            recommendedMode = 'transit';
            reason = 'Longue distance';
        }
    }
    
    return { 
        mode: recommendedMode, 
        reason: reason,
        weather: {
            condition: weatherData.current.condition.text,
            temperature: tempC,
            wind: windKph,
            icon: weatherData.current.condition.icon
        }
    };
}
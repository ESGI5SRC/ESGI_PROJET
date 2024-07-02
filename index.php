<?php
// Configuration de la base de données
$servername = getenv('DB_SERVER');
$username = getenv('DB_USERNAME');
$password = getenv('DB_PASSWORD');
$dbname = getenv('DB_NAME');

// Connexion à la base de données
$conn = new mysqli($servername, $username, $password, $dbname);

// Vérifier la connexion
if ($conn->connect_error) {
    die("Échec de la connexion : " . $conn->connect_error);
}

// Requête SQL pour récupérer les données
$sql = "SELECT * FROM votre_table";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Afficher les données dans un tableau HTML
    echo "<table border='1'>";
    echo "<tr><th>ID</th><th>Nom</th><th>Age</th></tr>"; // Adaptez les colonnes selon votre table
    while($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td>" . $row["id"] . "</td>"; // Adaptez les colonnes selon votre table
        echo "<td>" . $row["nom"] . "</td>"; // Adaptez les colonnes selon votre table
        echo "<td>" . $row["age"] . "</td>"; // Adaptez les colonnes selon votre table
        echo "</tr>";
    }
    echo "</table>";
} else {
    echo "0 résultats";
}

// Fermer la connexion
$conn->close();
?>

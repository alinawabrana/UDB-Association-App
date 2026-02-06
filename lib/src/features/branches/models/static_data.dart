import 'division_model.dart';

/// Static data for divisions, departments, and agents
/// This will be replaced with API data later

class StaticOrganesData {
  static List<Division> getDivisions() {
    return [
      // Cabinet du Président
      Division(
        id: '1',
        name: 'Cabinet du Président',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/udb_logo.png',
        departments: [],
      ),
      // Secrétariat Général
      Division(
        id: '2',
        name: 'Secrétariat Général',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/udb_logo.png',
        departments: [],
      ),
      // Estuaire
      Division(
        id: '3',
        name: 'Estuaire',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain. Nous identifions les lacunes industrielles dans les pays africains et concevons des solutions sur-mesure pour permettre la transformation durable et locale des matières premières, stimuler les exportations et promouvoir le commerce.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_estuaire.png',
        departments: [
          Department(
            id: '3-1',
            name: 'Komo',
            divisionId: '3',
            agents: [
              Agent(
                id: 'a1',
                name: 'EYUI MBOULOU',
                title: 'Rédactrice',
                role: 'COMMUNICATION',
                department: 'Komo',
                division: 'Estuaire',
                profileImage: null,
                province: 'Estuaire',
                departement: 'Komo',
                commune: 'Akanda',
                arrondissement: '2',
              ),
              Agent(
                id: 'a2',
                name: 'NOM COMPLET',
                title: 'Dépense',
                role: 'COMMUNICATION',
                department: 'Komo',
                division: 'Estuaire',
                profileImage: null,
              ),
            ],
          ),
          Department(
            id: '3-2',
            name: 'Komo-Mondah',
            divisionId: '3',
            agents: [],
          ),
          Department(
            id: '3-3',
            name: 'Noya',
            divisionId: '3',
            agents: [],
          ),
          Department(
            id: '3-4',
            name: 'Komo-Océan',
            divisionId: '3',
            agents: [],
          ),
        ],
      ),
      // Moyen-Ogooué
      Division(
        id: '4',
        name: 'Moyen-Ogooué',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_moyen_ogooue.png',
        departments: [
          Department(id: '4-1', name: 'Abanga-Bigné', divisionId: '4'),
          Department(id: '4-2', name: 'Ogooué et Lacs', divisionId: '4'),
        ],
      ),
      // Haut-Ogooué
      Division(
        id: '5',
        name: 'Haut-Ogooué',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_haut_ogooue.png',
        departments: [
          Department(id: '5-1', name: 'Djoué', divisionId: '5'),
          Department(id: '5-2', name: 'Djouori-Agnili', divisionId: '5'),
          Department(id: '5-3', name: 'Lébombi-Léyou', divisionId: '5'),
          Department(id: '5-4', name: 'Lékabi-Léwolo', divisionId: '5'),
          Department(id: '5-5', name: 'Lékoko', divisionId: '5'),
          Department(id: '5-6', name: 'Lékoni-Lékori', divisionId: '5'),
          Department(id: '5-7', name: 'Ogooué-Létili', divisionId: '5'),
          Department(id: '5-8', name: 'Mpassa', divisionId: '5'),
          Department(id: '5-9', name: 'Des plateaux', divisionId: '5'),
          Department(id: '5-10', name: 'Sébé-Brikolo', divisionId: '5'),
          Department(id: '5-11', name: 'Bayi Brikolo', divisionId: '5'),
        ],
      ),
      // Ngounié
      Division(
        id: '6',
        name: 'Ngounié',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_ngounie.png',
        departments: [
          Department(id: '6-1', name: 'Boumi-Louétsi', divisionId: '6'),
          Department(id: '6-2', name: 'Dola', divisionId: '6'),
          Department(id: '6-3', name: 'Douya-Onoy', divisionId: '6'),
          Department(id: '6-4', name: 'Louétsi-Wano', divisionId: '6'),
          Department(id: '6-5', name: 'Ndolou', divisionId: '6'),
          Department(id: '6-6', name: 'Ogoulou', divisionId: '6'),
          Department(id: '6-7', name: 'Tsamba-Magotsi', divisionId: '6'),
          Department(id: '6-8', name: 'Louétsi-Bibaka', divisionId: '6'),
          Department(id: '6-9', name: 'Mougalaba', divisionId: '6'),
        ],
      ),
      // Nyanga
      Division(
        id: '7',
        name: 'Nyanga',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_nyanga.png',
        departments: [
          Department(id: '7-1', name: 'Basse-Banio', divisionId: '7'),
          Department(id: '7-2', name: 'Douigni', divisionId: '7'),
          Department(id: '7-3', name: 'Doutsila', divisionId: '7'),
          Department(id: '7-4', name: 'Haute-Banio', divisionId: '7'),
          Department(id: '7-5', name: 'Mougoutsi', divisionId: '7'),
          Department(id: '7-6', name: 'Mongo', divisionId: '7'),
        ],
      ),
      // Ogooué-Ivindo
      Division(
        id: '8',
        name: 'Ogooué-Ivindo',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_ogooue_ivindo.png',
        departments: [
          Department(id: '8-1', name: 'Ivindo', divisionId: '8'),
          Department(id: '8-2', name: 'La Lopé', divisionId: '8'),
          Department(id: '8-3', name: 'Mvoung', divisionId: '8'),
          Department(id: '8-4', name: 'Zadié', divisionId: '8'),
        ],
      ),
      // Ogooué-Lolo
      Division(
        id: '9',
        name: 'Ogooué-Lolo',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_ogooue_lolo.png',
        departments: [
          Department(id: '9-1', name: 'Lolo-Bouenguidi', divisionId: '9'),
          Department(id: '9-2', name: 'Lombo Bouenguidi', divisionId: '9'),
          Department(id: '9-3', name: 'Mouloundou', divisionId: '9'),
          Department(id: '9-4', name: 'Offoué-Onoy', divisionId: '9'),
        ],
      ),
      // Ogooué-Maritime
      Division(
        id: '10',
        name: 'Ogooué-Maritime',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_ogooue_maritime.png',
        departments: [
          Department(id: '10-1', name: 'Bendjé', divisionId: '10'),
          Department(id: '10-2', name: 'Etimboué', divisionId: '10'),
          Department(id: '10-3', name: 'Ndougou', divisionId: '10'),
        ],
      ),
      // Woleu-Ntem
      Division(
        id: '11',
        name: 'Woleu-Ntem',
        description:
            'DÉVELOPPEUR PANAFRICAIN D\'ÉCOSYSTÈMES INDUSTRIELS ARISE Integrated Industrial Platforms (ARISE IIP) conçoit, finance, développe et exploite des systèmes industriels sur le continent africain.',
        phone: '+24160474511',
        email: 'arise@arise.com',
        logoPath: 'assets/images/division_woleu_ntem.png',
        departments: [
          Department(id: '11-1', name: 'Haut-Komo', divisionId: '11'),
          Department(id: '11-2', name: 'Haut-Ntem', divisionId: '11'),
          Department(id: '11-3', name: 'Ntem', divisionId: '11'),
          Department(id: '11-4', name: 'Okano', divisionId: '11'),
          Department(id: '11-5', name: 'Woleu', divisionId: '11'),
        ],
      ),
    ];
  }

  static List<Agent> getAllAgents() {
    final divisions = getDivisions();
    final List<Agent> allAgents = [];

    for (final division in divisions) {
      for (final department in division.departments) {
        allAgents.addAll(department.agents);
      }
    }

    // Add some additional agents
    allAgents.addAll([
      Agent(
        id: 'a3',
        name: 'Ogouebandja',
        title: 'Vice Présidente',
        role: 'PRESIDENCE',
        department: 'COMMUNICATION',
        division: 'Estuaire',
        profileImage: null,
        province: 'Estuaire',
        departement: 'Komo-Mondah',
        commune: 'Akanda',
        arrondissement: '2',
      ),
      Agent(
        id: 'a4',
        name: 'Christiana Bright',
        title: 'Responsable communication',
        role: 'COMMUNICATION',
        department: 'COMMUNICATION',
        division: 'Estuaire',
        phone: '07456721882',
        email: 'christiana@example.com',
        profileImage: null,
        province: 'Estuaire',
        departement: 'Komo-Mondah',
        commune: 'Akanda',
        arrondissement: '2',
      ),
    ]);

    return allAgents;
  }

  static Division? getDivisionById(String id) {
    try {
      return getDivisions().firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  static Department? getDepartmentById(String id) {
    for (final division in getDivisions()) {
      try {
        return division.departments.firstWhere((d) => d.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  static Agent? getAgentById(String id) {
    try {
      return getAllAgents().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Agent> getAgentsByDivision(String divisionId) {
    final division = getDivisionById(divisionId);
    if (division == null) return [];

    final List<Agent> agents = [];
    for (final department in division.departments) {
      agents.addAll(department.agents);
    }
    return agents;
  }

  static List<Agent> getAgentsByDepartment(String departmentId) {
    final department = getDepartmentById(departmentId);
    return department?.agents ?? [];
  }
}


import '../models/models.dart';

class BrandAssets {
  const BrandAssets._();

  static const logoMark = 'assets/brand/WLR_ICON_WR.svg';
  static const carRs6 = 'assets/brand/WLR_CAR_RS6.png';
  static const carEvo = 'assets/brand/WLR_CAR_EVO.png';
  static const yacht = 'assets/brand/WLR_cr5m8ccr5m8ccr5.png';
  static const monaco = 'assets/brand/4ip15b4ip15b4ip1.png';
  static const malta = 'assets/brand/1y9lb61y9lb61y9l.png';
  static const marbella = 'assets/brand/g2btng2btng2btng.png';
  static const dubai = 'assets/brand/laqs3ulaqs3ulaqs.png';
  static const f1Hero = 'assets/brand/sponsorship/f1/f1_hero_full.png';
  static const f1Side = 'assets/brand/sponsorship/f1/f1_side_detail.png';
}

class DemoData {
  const DemoData._();

  static const actRepoUrl = 'https://github.com/welrent/Act';

  static const cars = <Car>[
    Car(
      id: 1,
      name: 'an RS6',
      slug: 'an-RS6',
      subtitle: 'Rent...',
      photoUrl: BrandAssets.carRs6,
      isDarkMode: false,
      price: 120,
    ),
    Car(
      id: 2,
      name: 'an EVO',
      slug: 'an-EVO',
      subtitle: 'Rent...',
      photoUrl: BrandAssets.carEvo,
      isDarkMode: true,
      price: 150,
    ),
  ];

  static const navbar = <NavLink>[
    NavLink(title: 'Welrent Act', url: '/act'),
    NavLink(title: 'Locations', url: '/locations'),
    NavLink(title: 'Vehicles', url: '/offerlist'),
  ];

  static const footer = <String, List<NavLink>>{
    'Places': [
      NavLink(title: 'Rent in Amsterdam', url: '/locations/amsterdam'),
      NavLink(title: 'Rent in Rotterdam', url: '/locations/rotterdam'),
      NavLink(title: 'All destinations', url: '/locations'),
    ],
    'Special Cars': [
      NavLink(title: 'Electric Cars', url: '/offerlist?type=car'),
      NavLink(title: 'Motorbikes', url: '/offerlist?type=motorcycle'),
      NavLink(title: 'Boats & Yachts', url: '/offerlist?type=boat'),
    ],
    'Conditions': [
      NavLink(
        title: 'Car agreement (Act)',
        url: 'https://act.welrent.com/pages/car-rental-agreement',
      ),
      NavLink(
        title: 'Privacy (Act)',
        url: 'https://act.welrent.com/pages/privacy',
      ),
      NavLink(title: 'Terms (Act)', url: 'https://act.welrent.com/pages/terms'),
    ],
    'About': [
      NavLink(title: 'Welrent Act', url: '/act'),
      NavLink(title: 'Act on GitHub', url: actRepoUrl),
      NavLink(title: 'F1 Sponsorship', url: '/sponsorship/f1/wr/designed'),
    ],
  };

  static const content = SiteContent(
    footerBrandDesc: 'Welcome to Welrent, the smartest auto sharing and rental app. We guarantee the perfect car for every moment.',
    footerCopyright: '© 2026 Welrent App. Smart Agreements.',
  );

  static const locations = <String>[
    'Long Beach, California',
    'Amsterdam Central',
    'Rotterdam Airport',
    'Brussels Center',
  ];

  static const categories = <({String name, String image})>[
    (
      name: 'Hatchback',
      image: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?q=80&w=1200&auto=format&fit=crop',
    ),
    (
      name: 'Minivan',
      image: 'https://images.unsplash.com/photo-1570733577524-73d84f09fd33?q=80&w=1200&auto=format&fit=crop',
    ),
    (
      name: 'Sports Car',
      image: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1200&auto=format&fit=crop',
    ),
    (
      name: 'Pickup Truck',
      image: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop',
    ),
    (
      name: 'SUV',
      image: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=1200&auto=format&fit=crop',
    ),
  ];

  static const homeDestinations =
      <({String city, String slug, String price, String image})>[
        (
          city: 'Monaco',
          slug: 'monaco',
          price: 'from €1,200+',
          image: BrandAssets.monaco,
        ),
        (
          city: 'Malta',
          slug: 'malta',
          price: 'from €450+',
          image: BrandAssets.malta,
        ),
        (
          city: 'Marbella, Spain',
          slug: 'marbella',
          price: 'from €850+',
          image: BrandAssets.marbella,
        ),
        (
          city: 'Dubai Marina',
          slug: 'dubai-marina',
          price: 'from €1,100+',
          image: BrandAssets.dubai,
        ),
      ];

  static const regions =
      <
        ({
          String country,
          String flag,
          List<({String name, String slug})> cities,
        })
      >[
        (
          country: 'Nederland',
          flag: '🇳🇱',
          cities: [
            (name: 'Amsterdam', slug: 'amsterdam'),
            (name: 'Rotterdam', slug: 'rotterdam'),
            (name: 'Utrecht', slug: 'utrecht'),
            (name: 'Den Haag', slug: 'den-haag'),
            (name: 'Eindhoven', slug: 'eindhoven'),
          ],
        ),
        (
          country: 'België',
          flag: '🇧🇪',
          cities: [
            (name: 'Brussel', slug: 'brussels'),
            (name: 'Antwerpen', slug: 'antwerp'),
            (name: 'Gent', slug: 'gent'),
            (name: 'Brugge', slug: 'brugge'),
            (name: 'Luik', slug: 'luik'),
          ],
        ),
      ];

  static const actPages = <ActPageLink>[
    ActPageLink(
      title: 'Car rental agreement',
      body: 'Smart contract template for passenger vehicles.',
      path: '/pages/car-rental-agreement',
    ),
    ActPageLink(
      title: 'Boat rental agreement',
      body: 'Agreements for boats and yachts on Welrent Act.',
      path: '/pages/boat-rental-agreement',
    ),
    ActPageLink(
      title: 'Equipment rental agreement',
      body: 'Gear and equipment rental terms powered by Act.',
      path: '/pages/equipment-rental-agreement',
    ),
    ActPageLink(
      title: 'Terms of Service',
      body: 'Platform rules published from the Act legal pages.',
      path: '/pages/terms',
    ),
    ActPageLink(
      title: 'Privacy Statement',
      body: 'How Welrent Act collects and protects personal data.',
      path: '/pages/privacy',
    ),
    ActPageLink(
      title: 'Cookie Statement',
      body: 'Cookie and tracking disclosures from Act.',
      path: '/pages/cookie',
    ),
    ActPageLink(
      title: 'Accessibility',
      body: 'Act accessibility commitment.',
      path: '/pages/accessibility',
    ),
    ActPageLink(
      title: 'Agreements desk',
      body: 'Browse and manage rental agreements in Act.',
      path: '/agreements',
    ),
  ];

  static const bookings = <Booking>[
    Booking(
      id: 'WLR-8829',
      type: 'car',
      name: 'Audi RS6 Avant',
      image: BrandAssets.carRs6,
      status: 'Confirmed',
      dates: 'Apr 24 - Apr 27, 2026',
      location: 'Monaco Harbor',
      total: '€2,850',
      active: true,
    ),
    Booking(
      id: 'WLR-7712',
      type: 'boat',
      name: 'Mangusta 108',
      image: 'https://images.unsplash.com/photo-1567899103394-47306264515b?q=80&w=800&auto=format&fit=crop',
      status: 'Completed',
      dates: 'Mar 15 - Mar 16, 2026',
      location: 'Dubai Marina',
      total: '€12,500',
      active: false,
    ),
  ];

  static List<Conversation> conversations() {
    return [
      Conversation(
        id: 1,
        name: 'Marco (Owner)',
        time: '10:45 AM',
        online: true,
        avatar: 'https://i.pravatar.cc/150?u=marco',
        messages: const [
          ChatMessage(
            id: 1,
            sender: 'other',
            text: 'Hello! I am ready to hand over the keys for the Audi RS6.',
            time: '10:30 AM',
          ),
          ChatMessage(
            id: 2,
            sender: 'me',
            text: 'Great! I am 10 minutes away from the location.',
            time: '10:32 AM',
          ),
          ChatMessage(
            id: 3,
            sender: 'other',
            text: 'Perfect. I am parked near the main entrance of the Marina.',
            time: '10:40 AM',
          ),
          ChatMessage(
            id: 4,
            sender: 'other',
            text: 'The car is ready for you!',
            time: '10:45 AM',
          ),
        ],
      ),
      const Conversation(
        id: 2,
        name: 'Elena (Yacht Concierge)',
        time: 'Yesterday',
        avatar: 'https://i.pravatar.cc/150?u=elena',
        messages: [
          ChatMessage(
            id: 1,
            sender: 'other',
            text: 'Shall I prepare the drinks?',
            time: 'Yesterday',
          ),
        ],
      ),
      const Conversation(
        id: 3,
        name: 'Dubai Rentals',
        time: 'Monday',
        avatar: 'https://i.pravatar.cc/150?u=dubai',
        messages: [
          ChatMessage(
            id: 1,
            sender: 'other',
            text: 'Your booking is confirmed.',
            time: 'Monday',
          ),
        ],
      ),
    ];
  }

  static const notifications = <AppNotification>[
    AppNotification(
      id: 1,
      type: 'booking',
      title: 'Booking Confirmed!',
      description: 'Your request for the Audi RS6 in Monaco has been confirmed by the owner.',
      time: '2 hours ago',
      unread: true,
    ),
    AppNotification(
      id: 2,
      type: 'system',
      title: 'Promotion: Summer in Dubai',
      description: 'Get 15% off all yacht rentals in Dubai Marina for the month of June.',
      time: '1 day ago',
      unread: false,
    ),
    AppNotification(
      id: 3,
      type: 'alert',
      title: 'Identity Verified',
      description:
          "Great news! Your driver's license has been successfully verified.",
      time: '3 days ago',
      unread: false,
    ),
    AppNotification(
      id: 4,
      type: 'booking',
      title: 'Review your trip',
      description:
          'How was your experience in Monaco? Share your feedback now.',
      time: '1 week ago',
      unread: false,
    ),
  ];

  static Car? vehicleBySlug(String slug, List<Car> cars) {
    for (final car in cars) {
      if (car.matchesSlug(slug)) return car;
    }
    return null;
  }

  static Catalog demoCatalog() {
    return const Catalog(
      cars: cars,
      navbar: navbar,
      footer: footer,
      content: content,
    );
  }
}

class DestinationData {
  const DestinationData._();

  static const destinations = <String, Destination>{
    'monaco': Destination(
      slug: 'monaco',
      name: 'Monaco',
      fullName: 'Monaco (Monte Carlo)',
      price: 'from €1,200+',
      image: BrandAssets.monaco,
      about: 'Experience the pinnacle of Mediterranean luxury in Monaco. From the legendary Casino de Monte-Carlo to the world-famous Grand Prix circuit, Monaco is a playground for the elite. Our fleet in the Principality features only the finest hypercars and superyachts, ensuring you move through its glamorous streets and turquoise waters with unparalleled prestige.',
      cars: [
        FleetItem(
          name: 'Ferrari F8 Spider',
          price: '€1,800/day',
          specs: '710 HP | 2.9s 0-100',
          image: 'https://images.unsplash.com/photo-1592198084033-aade902d1aae?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Lamborghini Huracán EVO',
          price: '€1,650/day',
          specs: '640 HP | AWD',
          image: 'https://images.unsplash.com/photo-1511919884226-c90a15321685?q=80&w=800&auto=format&fit=crop',
        ),
      ],
      boats: [
        FleetItem(
          name: 'Mangusta 108',
          price: '€12,500/day',
          specs: '33m | 12 Guests',
          image: 'https://images.unsplash.com/photo-1567899103394-47306264515b?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Pershing 82',
          price: '€9,800/day',
          specs: '25m | 35 knots',
          image: 'https://images.unsplash.com/photo-1569263979104-865ab7cd8d13?q=80&w=800&auto=format&fit=crop',
        ),
      ],
    ),
    'malta': Destination(
      slug: 'malta',
      name: 'Malta',
      fullName: 'Valletta & The Islands',
      price: 'from €450+',
      image: BrandAssets.malta,
      about: 'Malta combines 7,000 years of history with a vibrant, modern island lifestyle. Navigate the honey-colored streets of Valletta or sail to the crystal-clear Blue Lagoon of Comino. Our Malta selection balances historic charm with modern performance, offering versatile SUVs for inland exploration and elegant sailing vessels for the archipelago.',
      cars: [
        FleetItem(
          name: 'Range Rover Sport',
          price: '€450/day',
          specs: 'Luxury SUV | AWD',
          image: 'https://images.unsplash.com/photo-1541443131876-44b03de101c5?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Mercedes-Benz G-Class',
          price: '€650/day',
          specs: 'Off-road King',
          image: 'https://images.unsplash.com/photo-1520031441870-4c041ad35613?q=80&w=800&auto=format&fit=crop',
        ),
      ],
      boats: [
        FleetItem(
          name: 'Bavaria C45',
          price: '€1,200/day',
          specs: '14m | Sailing Yacht',
          image: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Princess V55',
          price: '€3,500/day',
          specs: '17m | Motor Yacht',
          image: 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?q=80&w=800&auto=format&fit=crop',
        ),
      ],
    ),
    'marbella': Destination(
      slug: 'marbella',
      name: 'Marbella',
      fullName: 'Marbella & Puerto Banús',
      price: 'from €850+',
      image: BrandAssets.marbella,
      about: 'From the exclusive Golden Mile to the high-end boutiques of Puerto Banús, Marbella is the crown jewel of the Costa del Sol. Enjoy year-round sunshine in a convertible supercar or host an unforgettable afternoon on a luxury catamaran. Welrent Marbella puts the keys to the Mediterranean lifestyle in the palm of your hand.',
      cars: [
        FleetItem(
          name: 'Porsche 911 Carrera S',
          price: '€850/day',
          specs: 'Convertible | 450 HP',
          image: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Aston Martin Vantage',
          price: '€1,100/day',
          specs: 'V8 | British Elegance',
          image: 'https://images.unsplash.com/photo-1593452093510-019685ed199d?q=80&w=800&auto=format&fit=crop',
        ),
      ],
      boats: [
        FleetItem(
          name: 'Sunseeker Predator 68',
          price: '€5,500/day',
          specs: '21m | 6 Guests',
          image: 'https://images.unsplash.com/photo-1567899103394-47306264515b?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Lagoon 450 F',
          price: '€1,800/day',
          specs: '14m | Luxury Catamaran',
          image: 'https://images.unsplash.com/photo-1621275471769-e6aa344546d5?q=80&w=800&auto=format&fit=crop',
        ),
      ],
    ),
    'dubai-marina': Destination(
      slug: 'dubai-marina',
      name: 'Dubai Marina',
      fullName: 'Dubai Marina & The Palm',
      price: 'from €1,100+',
      image: BrandAssets.dubai,
      about: 'Dubai Marina is where futuristic architecture meets the Arabian Gulf. Drive through a canyon of skyscrapers in a McLaren or cruise around the Palm Jumeirah on a triple-deck yacht. In a city where everything is bigger and better, Welrent providing the ultimate fleet to match its world-class standards.',
      cars: [
        FleetItem(
          name: 'McLaren 720S',
          price: '€1,200/day',
          specs: '720 HP | Carbon Fiber',
          image: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Rolls-Royce Cullinan',
          price: '€2,500/day',
          specs: 'Ultra Luxury SUV',
          image: 'https://images.unsplash.com/photo-1631214499558-75e1823eb91e?q=80&w=800&auto=format&fit=crop',
        ),
      ],
      boats: [
        FleetItem(
          name: 'Azimut 80',
          price: '€4,500/hour',
          specs: '24m | Italian Style',
          image: 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?q=80&w=800&auto=format&fit=crop',
        ),
        FleetItem(
          name: 'Sanlorenzo SL102',
          price: '€18,000/day',
          specs: '31m | Asymmetric Design',
          image: 'https://images.unsplash.com/photo-1569263979104-865ab7cd8d13?q=80&w=800&auto=format&fit=crop',
        ),
      ],
    ),
  };

  /// Unknown slugs fall back to Monaco, matching the Next.js city page.
  static Destination resolve(String slug) {
    return destinations[slug.toLowerCase()] ?? destinations['monaco']!;
  }
}

class LegalCopy {
  const LegalCopy._();

  static const terms = <({String title, String body})>[
    (
      title: '1. Acceptance of Terms',
      body: 'By creating a Welrent account or using our platform you agree to these Terms of Service and our Privacy Policy. If you do not agree, you may not use the service. These terms constitute a binding legal agreement between you and Welrent B.V.',
    ),
    (
      title: '2. Eligibility',
      body: 'You must be at least 21 years old, hold a valid driving licence recognised in the country of rental, and have held that licence for a minimum of 2 years. Corporate accounts may set additional eligibility criteria.',
    ),
    (
      title: '3. Booking & Payment',
      body: 'Bookings are confirmed upon successful payment authorisation. Prices are inclusive of VAT and the standard insurance package. Optional extras (GPS, child seat, additional driver) are itemised at checkout. We reserve the right to cancel bookings in cases of suspected fraud.',
    ),
    (
      title: '4. Vehicle Use',
      body: 'Vehicles must be used only by authorised drivers listed on the booking. Smoking, pets (unless specifically permitted) and off-road use are prohibited. You are responsible for traffic violations, tolls and parking fines incurred during your booking period.',
    ),
    (
      title: '5. Cancellation Policy',
      body: 'Cancellations made more than 24 hours before the scheduled pick-up time receive a full refund. Cancellations within 24 hours forfeit 50% of the booking value. No-shows forfeit the full booking amount.',
    ),
    (
      title: '6. Insurance & Liability',
      body: 'A basic Collision Damage Waiver (CDW) and Theft Protection (TP) are included in every booking. The excess (own risk) is stated on the booking confirmation. You may purchase excess waiver to reduce your liability to €0. Wilful damage and DUI incidents void all cover.',
    ),
    (
      title: '7. Damage Reporting',
      body: 'Any damage discovered at pick-up must be documented in the Welrent app before departing. Damage reported after return that is not pre-documented will be charged to the driver. A damage assessment report will be provided within 5 business days.',
    ),
    (
      title: '8. Platform Rules',
      body: 'You may not scrape, reverse-engineer or commercially resell access to the Welrent platform. Accounts found to list fraudulent vehicles or submit false reviews will be permanently banned and may face legal action.',
    ),
    (
      title: '9. Governing Law',
      body: 'These Terms are governed by Dutch law. Disputes shall be submitted to the competent court in Amsterdam, the Netherlands, unless mandatory consumer-protection rules in your country of residence require otherwise.',
    ),
    (
      title: '10. Changes to Terms',
      body: 'We may update these Terms at any time. We will notify you via email and in-app notification at least 30 days before material changes take effect. Continued use after that date constitutes acceptance.',
    ),
  ];

  static const privacy = <({String title, String body})>[
    (
      title: '1. Who We Are',
      body: 'Welrent B.V. ("Welrent", "we", "our") operates a premium car-sharing and rental marketplace available via welrent.com and the Welrent mobile application. We are headquartered in Amsterdam, the Netherlands, and registered with the Dutch Chamber of Commerce.',
    ),
    (
      title: '2. Data We Collect',
      body: 'We collect information you provide directly (name, email, phone number, driving licence, payment details) and data generated automatically when you use our services (IP address, device identifiers, location data when you unlock a vehicle, booking history and in-app behaviour).',
    ),
    (
      title: '3. How We Use Your Data',
      body: 'Your personal data is used to fulfil bookings, process payments, provide customer support, improve our platform, send transactional communications, comply with legal obligations and prevent fraud. We do not sell your personal data to third parties.',
    ),
    (
      title: '4. Legal Basis (GDPR)',
      body: 'Processing is based on: (a) performance of a contract when you book a vehicle; (b) your consent for marketing communications; (c) legitimate interests for fraud prevention and service improvement; and (d) compliance with legal obligations.',
    ),
    (
      title: '5. Data Sharing',
      body: 'We share data with vehicle partners to facilitate pick-up, payment processors (Stripe, Adyen), identity verification providers and, when legally required, public authorities. All processors are bound by data processing agreements compliant with GDPR.',
    ),
    (
      title: '6. Cookies',
      body: 'We use essential cookies required for the site to function and, with your consent, analytics and marketing cookies. You can manage your cookie preferences at any time via our Cookie Settings panel.',
    ),
    (
      title: '7. Data Retention',
      body: 'We retain personal data for as long as your account is active or as needed to provide services. Booking records are kept for 7 years to comply with Dutch tax law. Driver-licence scans are deleted 30 days after a booking concludes.',
    ),
    (
      title: '8. Your Rights',
      body: 'Under the GDPR you have the right to access, rectify, erase, restrict processing of, and port your data, as well as the right to object. Submit requests to privacy@welrent.com. You may also lodge a complaint with the Autoriteit Persoonsgegevens (AP).',
    ),
    (
      title: '9. Security',
      body: 'We protect your data using TLS encryption in transit, AES-256 encryption at rest, access controls, regular penetration testing and SOC 2-aligned security practices.',
    ),
    (
      title: '10. Contact',
      body: 'Welrent B.V. · Keizersgracht 123, 1015 CW Amsterdam, Netherlands · privacy@welrent.com',
    ),
  ];
}

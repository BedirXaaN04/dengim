import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
    title: "DENGIM Admin Panel",
    description: "DENGIM Dating App - Admin & VIP Management Platform",
};

import { AuthProvider } from "@/components/layout/AuthProvider";

// ...

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="tr" className="dark">
            <head>
                <link
                    href="https://fonts.googleapis.com/css2?family=Manrope:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet"
                />
                <link
                    href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap"
                    rel="stylesheet"
                />
            </head>
            <body className="font-display antialiased">
                <AuthProvider>
                    {children}
                </AuthProvider>
            </body>
        </html>
    );
}

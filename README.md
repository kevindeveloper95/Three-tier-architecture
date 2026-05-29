# ☕ Ritual Roast

Tu app web (Flask + React) viviendo en AWS, con la infra montada en Terraform para que no tengas que clicar mil cosas en la consola.

¿Primera vez por aquí? Este README te guía paso a paso. Si lo tuyo es la nube, salta directo a la [guía de Terraform](terraform/aws/README.md).

---

## 📁 Qué hay en este repo

| Carpeta | Para qué sirve |
|---------|----------------|
| [`ritual-roast-app/`](ritual-roast-app/) | La app en sí: API Flask y el frontend ya compilado en `flask/ritual_roast/build` |
| [`terraform/aws/`](terraform/aws/) | Toda la infra en AWS: red, balanceador, servidores, base de datos, S3, secretos… |
| [`Diagram/`](Diagram/) | Diagramas de arquitectura (draw.io) por si te ayuda a visualizarlo |

---

## 🗺️ Diagrama de arquitectura

![Diagrama de arquitectura AWS — Ritual Roast](Diagram/Arquitectura-SSA.png)

*Fuente editable:* [`Diagram/Arquitectura-SSA.drawio`](Diagram/Arquitectura-SSA.drawio)

El dibujo resume lo que Terraform despliega: **tres capas en dos zonas de disponibilidad**, dentro de una VPC.

| Capa | Qué hay | Para qué |
|------|---------|----------|
| 🌐 **DMZ (subnets públicas)** | Internet Gateway, ALB (:80), NAT Gateway | Entrada desde internet y salida a internet de las subnets privadas |
| 🖥️ **Web / app (subnets privadas)** | ASG, EC2, Launch Template, Target Group (:5000) | Flask + React; el ALB reparte tráfico entre instancias |
| 🗄️ **Datos (subnets privadas)** | RDS MySQL Multi-AZ (:3306), Lambda de rotación | Base de datos aislada; Lambda rota credenciales en Secrets Manager |

**Flujo de una petición:** Internet → ALB (80) → instancias EC2 (5000) → MySQL (3306), si la app lo necesita.

**Otros elementos del diagrama:**

- **S3 + user-data:** al arrancar, la EC2 baja el código del bucket (no va en la imagen AMI).
- **Secrets Manager + IAM:** la app lee el JSON con host, usuario y contraseña MySQL; los roles IAM dan permiso sin guardar secretos en Git.
- **Security groups:** Load Balancer → Web App (5000) → Database (3306), como en el código.

> **Nota sobre el dibujo vs. Terraform actual**  
> La **lógica** del diagrama encaja con el repo. Algunas **etiquetas** son de un diseño anterior: el diagrama muestra VPC `10.16.0.0/16` y subnets `/20`, mientras que el default en `terraform.tfvars` es `10.0.0.0/16` con subnets `/24`. Las AZ del dibujo dicen `eu-west-2a/b` pero la región por defecto es `us-east-1` (Terraform usa las AZ reales de la región que configures). Si cambias `vpc_cidr` o `aws_region`, el esquema sigue igual; solo cambian los CIDR y nombres de zona.

---

## 🏗️ Cómo está montado (en pocas palabras)

Imagina el camino de un visitante:

1. Llega al **balanceador (ALB)** en la red pública.
2. El tráfico va a las **EC2** del grupo de autoescalado, en una red privada, puerto **5000**.
3. Al arrancar, cada servidor baja el código desde **S3** y pide la contraseña de MySQL a **Secrets Manager** (nada hardcodeado en el repo).
4. La base **RDS MySQL** vive en otra subred privada, solo accesible desde la app.
5. Si necesitas entrar a una máquina, lo haces con **SSM Session Manager** (sin abrir SSH al mundo).

Más detalle técnico → **[terraform/aws/README.md](terraform/aws/README.md)**.

---

## 🧰 Antes de empezar

Necesitarás:

- Una **cuenta AWS** con permisos para crear VPC, EC2, RDS, S3, IAM…
- **[Terraform](https://developer.hashicorp.com/terraform/install)** 1.1 o superior
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** configurado (`aws configure` o variables de entorno)
- **Python 3.9+** si quieres probar la app en tu máquina

---

## 🚀 Ponerlo en marcha

### 1️⃣ Levantar la infra

```bash
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars
# Abre terraform.tfvars y ajusta lo que necesites (región, entorno, etc.)
terraform init
terraform plan
terraform apply
```

Cuando termine, guarda estos datos (te los da Terraform):

```bash
terraform output alb_dns_name
terraform output s3_bucket_name
terraform output rds_mysql_credentials_secret_name
```

### 2️⃣ Subir la app al bucket S3

Terraform ya creó el bucket; tú solo subes el código:

```bash
aws s3 sync ritual-roast-app/ s3://<nombre-del-bucket>/ --region <tu-region>
```

*(Sustituye `<nombre-del-bucket>` y `<tu-region>` por lo que viste en los outputs.)*

### 3️⃣ Que las instancias pillen el código nuevo

Las EC2 se configuran solas al arrancar (`user-data`), pero si ya estaban levantadas, refresca el ASG o sustituye instancias para que vuelvan a ejecutar el script y bajen lo último de S3.

### 4️⃣ Comprobar que respira

Abre en el navegador:

`http://<alb_dns_name>/health`

Si ves OK, vas bien. Si no, mira los logs en la instancia o la sección de problemas en la doc de Terraform.

---

## 💻 Probar la app en local

Sin AWS, solo para desarrollar:

```bash
cd ritual-roast-app/flask
python3 -m venv .venv
source .venv/bin/activate          # En Windows: .venv\Scripts\activate
pip install -r requirements.txt
# Aquí configura MYSQL_SECRET_NAME o credenciales locales como prefieras
python3 ritual-roast.py
```

---

## 📚 Más lectura

- [Guía completa de Terraform (AWS)](terraform/aws/README.md)
- Variables y outputs: `terraform/aws/variables.tf` y `outputs.tf`
- Plantilla de configuración: `terraform/aws/terraform.tfvars.example`

---

## 🔒 Un aviso de seguridad (importante)

- **No subas** `terraform.tfvars` ni archivos `.env` a GitHub: pueden llevar contraseñas. Ya están en `.gitignore`, pero revísalo antes de cada `git push`.
- En **producción**, cambia cosas como `deletion_protection` en RDS, snapshots y `s3_bucket_force_destroy` (en dev está pensado para poder borrar todo rápido).

---

## 📄 Licencia

Añade aquí la licencia cuando la tengas definida.

apiVersion: v1
items:
- apiVersion: v1
  kind: Secret
  metadata:
    annotations:
      template.openshift.io/expose-database_name: '{.data[''database-name'']}'
      template.openshift.io/expose-password: '{.data[''database-password'']}'
      template.openshift.io/expose-username: '{.data[''database-user'']}'
    labels:
      template: postgresql-ephemeral-template
    name: postgresql
  stringData:
    database-name: sampledb
    database-password: ytVYFJATLYKykBPa
    database-user: userS3W
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      template.openshift.io/expose-uri: postgres://{.spec.clusterIP}:{.spec.ports[?(.name=="postgresql")].port}
    labels:
      template: postgresql-ephemeral-template
    name: postgresql
  spec:
    ports:
    - name: postgresql
      nodePort: 0
      port: 5432
      protocol: TCP
      targetPort: 5432
    selector:
      name: postgresql
    sessionAffinity: None
    type: ClusterIP
  status:
    loadBalancer: {}
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    annotations:
      template.alpha.openshift.io/wait-for-ready: "true"
    labels:
      template: postgresql-ephemeral-template
    name: postgresql
  spec:
    replicas: 1
    selector:
      name: postgresql
    strategy:
      type: Recreate
    template:
      metadata:
        labels:
          name: postgresql
      spec:
        containers:
        - capabilities: {}
          env:
          - name: POSTGRESQL_USER
            valueFrom:
              secretKeyRef:
                key: database-user
                name: postgresql
          - name: POSTGRESQL_PASSWORD
            valueFrom:
              secretKeyRef:
                key: database-password
                name: postgresql
          - name: POSTGRESQL_DATABASE
            valueFrom:
              secretKeyRef:
                key: database-name
                name: postgresql
          image: ' '
          imagePullPolicy: IfNotPresent
          livenessProbe:
            exec:
              command:
              - /usr/libexec/check-container
              - --live
            initialDelaySeconds: 120
            timeoutSeconds: 10
          name: postgresql
          ports:
          - containerPort: 5432
            protocol: TCP
          readinessProbe:
            exec:
              command:
              - /usr/libexec/check-container
            initialDelaySeconds: 5
            timeoutSeconds: 1
          resources:
            limits:
              memory: 512Mi
          securityContext:
            capabilities: {}
            privileged: false
          terminationMessagePath: /dev/termination-log
          volumeMounts:
          - mountPath: /var/lib/pgsql/data
            name: postgresql-data
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        volumes:
        - emptyDir:
            medium: ""
          name: postgresql-data
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - postgresql
        from:
          kind: ImageStreamTag
          name: postgresql:10-el8
          namespace: openshift
        lastTriggeredImage: ""
      type: ImageChange
    - type: ConfigChange
  status: {}
kind: List
metadata: {}
